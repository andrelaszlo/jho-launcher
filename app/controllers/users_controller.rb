# coding: utf-8
class UsersController < ApplicationController
  def placeholder
    @bodyId = 'placeholder'
    @noCookieBanner = true

    respond_to do |format|
      format.html # placeholder.html.erb
    end
  end

  def new
    @statsd.increment 'landing_page'
    @bodyId = 'home'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    ref_code = cookies[:h_ref]
    email = params[:user][:email]

    @user = User.find_by_email(email)
    if not @user.nil?
      sign_in email
      redirect_to_referral_page
      return
    end

    if ip_block
      return redirect_to root_url, alert: "Oups ! Trop d’emails ont été renseignés depuis cette adresse IP"
    end

    @user = User.new(email: email)
    @user.referrer = User.find_by_referral_code(ref_code) if ref_code

    if @user.save
      @statsd.increment 'signup'
      sign_in @user.email
      redirect_to_referral_page
    else
      @statsd.increment 'signup_error'
      logger.info("Error saving user with email, #{email}")
      puts "Redirecting using host #{root_url}"
      redirect_to root_url, alert: "Une erreur s’est produite", host: root_url
    end
  end

  def referral
    ref = params[:id]

    unless User.find_by_referral_code(ref).nil?
      h_ref = { value: ref, expires: 1.week.from_now }
      cookies[:h_ref] = h_ref
    end

    redirect_to root_url, host: root_url
  end

  def refer
    @bodyId = 'refer'

    user_email = params[:email] || cookies[:h_email]  # Prioritize query string

    @user = User.find_by_email(user_email)

    if not @user.nil?
      @progressMax = 50.0
      @referralsCount = @user.referrals.count

      # The following is calculated manually
      # Not the prettiest algorithm, but it works
      @progressPercent = 0
      if @referralsCount <= 5
        width = 20.0 + 20.0/2
        @progressPercent = width * @referralsCount/5.0
      elsif @referralsCount <= 10
        base = 20.0 + 20.0/2
        width = 20.0
        @progressPercent = base + (width * (@referralsCount-5)/5.0)
      elsif @referralsCount <= 25
        base = 40.0 + 20.0/2
        width = 20.0
        @progressPercent = base + (width * (@referralsCount-10)/15.0)
      else
        base = 60.0 + 25.0/2
        width = 19.0
        @progressPercent = [base + (width * (@referralsCount-25)/25.0), 100].min
      end

      @progressPercent = [@progressPercent, 5].max

      @referral_link = "#{root_url.chomp '/'}/r/#{@user.referral_code}"
      @referral_link_urlencoded = CGI.escape @referral_link
      @twitter_msg = {:text => "@_jho_fr arrive sur #{@referral_link} ! ENFIN des #tampons et #serviettes livrés chez vous...en #cotonbio",
                      :url => " "}.to_param.gsub "+", "%20"
    end

    respond_to do |format|
      if @user.nil?
        @statsd.increment 'referral_page_error'
        puts "Redirecting using host #{root_url}"
        format.html { redirect_to root_url, alert: "Une erreur s’est produite", host: root_url }
      else
        @statsd.increment 'referral_page'
        format.html # refer.html.erb
      end
    end
  end

  def policy
    @bodyId = 'policy'
  end

  def redirect
    puts "Redirectign using #{root_url}"
    redirect_to root_url, status: 404, host: root_url
  end

  private

  def sign_in(email)
    cookies[:h_email] = { value: email }
  end

  def redirect_to_referral_page
    # This is a workaround for some nginx behavior we can't control
    puts "Redirecting using host #{root_url}"
    redirect_to :controller => 'users', :action => 'refer', :host => root_url.chomp('/')
  end

  def ip_block
    # Prevent someone from gaming the site by referring themselves.
    # Presumably, users are doing this from the same device so block
    # their ip after their ip appears three times in the database.

    ip_limit = Rails.application.config.ip_limit
    address = remote_ip
    return if address.nil?

    current_ip = IpAddress.find_by_address(address)
    if current_ip.nil?
      current_ip = IpAddress.create(address: address, count: 1)
    elsif current_ip.count >= ip_limit
      @statsd.increment 'ip_block'
      logger.info("IP address #{address} has already appeared #{current_ip.count} times in our records.
                   Redirecting user back to landing page.")
      return true
    else
      current_ip.count += 1
      current_ip.save
    end

    return false
  end

  def remote_ip
    # Unfortunately, request.remote_ip seems to prefer HTTP_X_REAL_IP
    # but in our case HTTP_X_FORWARDED_FOR has the user's ip.
    forwarded_for = request.env['HTTP_X_FORWARDED_FOR'] || ""
    forwarded_for_ip = forwarded_for.split(',').first
    return forwarded_for_ip || request.remote_ip
  end
end
