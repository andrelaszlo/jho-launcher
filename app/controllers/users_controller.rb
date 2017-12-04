class UsersController < ApplicationController
  before_filter :skip_first_page, only: :new
  before_filter :handle_ip, only: :create

  def placeholder
    @bodyId = 'placeholder'

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
    @user = User.new(email: email)
    @user.referrer = User.find_by_referral_code(ref_code) if ref_code

    if @user.save
      @statsd.increment 'signup'
      cookies[:h_email] = { value: @user.email }
      redirect_to_referral_page
    else
      @statsd.increment 'signup_error'
      logger.info("Error saving user with email, #{email}")
      puts "Redirecting using host #{root_url}"
      redirect_to root_url, alert: 'Something went wrong!', host: root_url
    end
  end

  def refer
    @bodyId = 'refer'

    @user = User.find_by_email(cookies[:h_email])

    if not @user.nil?
      @progressMax = 25.0
      @referralsCount = @user.referrals.count

      # The following is calculated manually
      # Not the prettiest algorithm, but it works
      @progressPercent = 0
      if @referralsCount <= 5
        width = 25.0 + 25.0/2
        @progressPercent = width * @referralsCount/5.0
      elsif @referralsCount <= 10
        base = 25.0 + 25.0/2
        width = 25.0
        @progressPercent = base + (width * (@referralsCount-5)/5.0)
      else
        base = 50.0 + 25.0/2
        width = 26.0
        @progressPercent = [base + (width * (@referralsCount-10)/15.0), 100].min
      end
    end

    respond_to do |format|
      if @user.nil?
        @statsd.increment 'referral_page_error'
        puts "Redirecting using host #{root_url}"
        format.html { redirect_to root_url, alert: 'Something went wrong!', host: root_url }
      else
        @statsd.increment 'referral_page'
        format.html # refer.html.erb
      end
    end
  end

  def policy
  end

  def redirect
    puts "Redirectign using #{root_url}"
    redirect_to root_url, status: 404, host: root_url
  end

  private

  def skip_first_page
    return if Rails.application.config.ended

    email = cookies[:h_email]
    if email && User.find_by_email(email)
      redirect_to_referral_page
    else
      cookies.delete :h_email
    end
  end

  def redirect_to_referral_page
    # This is a workaround for some nginx behavior we can't control
    puts "Redirecting using host #{root_url}"
    redirect_to :controller => 'users', :action => 'refer', :host => root_url.chomp('/')
  end

  def handle_ip
    # Prevent someone from gaming the site by referring themselves.
    # Presumably, users are doing this from the same device so block
    # their ip after their ip appears three times in the database.

    address = remote_ip
    puts "Detected IP #{address}"
    return if address.nil?

    current_ip = IpAddress.find_by_address(address)
    if current_ip.nil?
      current_ip = IpAddress.create(address: address, count: 1)
    elsif current_ip.count >= 9
      @statsd.increment 'ip_block'
      logger.info('IP address has already appeared three times in our records.
                 Redirecting user back to landing page.')
      return redirect_to root_url
    else
      current_ip.count += 1
      current_ip.save
    end
  end

  def remote_ip
    # Unfortunately, request.remote_ip seems to prefer HTTP_X_REAL_IP
    # but in our case HTTP_X_FORWARDED_FOR has the user's ip.
    forwarded_for = request.env['HTTP_X_FORWARDED_FOR'] || ""
    forwarded_for_ip = forwarded_for.split(',').first
    return forwarded_for_ip || request.remote_ip
  end
end
