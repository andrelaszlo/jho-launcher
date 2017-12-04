class UserMailer < ActionMailer::Base
  default from: "jho. <bienvenue@jho.fr>"

  def signup_email(user)
    config = Rails.application.config
    @user = user
    @host = config.action_controller.default_url_options[:host]
    @mailer_host = config.action_mailer.default_url_options[:host] || ""
    @twitter_message = "Follow jho on Twitter"
    @ref_url = "#{@mailer_host}?ref=#{@user.referral_code}"
    @login_url = "#{@host}/refer-a-friend/?email=#{@user.email}"

    @social_facebook = Rails.application.config.social_facebook
    @social_twitter = Rails.application.config.social_twitter
    @social_instagram = Rails.application.config.social_instagram

    mail(:to => user.email, :subject => "Bienvenue chez jho")
  end
end
