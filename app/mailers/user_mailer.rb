class UserMailer < ActionMailer::Base
  default from: "jho. <bienvenue@jho.fr>"

  def signup_email(user)
    config = Rails.application.config
    @user = user
    @host = config.action_controller.default_url_options[:host]
    @mailer_host = config.action_mailer.default_url_options[:host] || ""
    @twitter_message = "Follow jho on Twitter"
    @ref_url = "#{@mailer_host.chomp '/'}/r/#{@user.referral_code}"
    querystring = {:email => @user.email}.to_param
    @login_url = "#{@host}/refer-a-friend/?#{querystring}"

    @social_facebook = Rails.application.config.social_facebook
    @social_twitter = Rails.application.config.social_twitter
    @social_instagram = Rails.application.config.social_instagram

    mail(:to => user.email, :subject => "Bienvenue chez jho")
  end
end
