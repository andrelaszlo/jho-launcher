class UserMailer < ActionMailer::Base
  default from: "jho <bienvenue@jho.fr>"

  def signup_email(user)
    @user = user
    @twitter_message = "Follow jho on Twitter"

    mail(:to => user.email, :subject => "Thanks for signing up!")
  end
end
