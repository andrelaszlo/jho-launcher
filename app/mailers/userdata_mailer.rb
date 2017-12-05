class UserdataMailer < ActionMailer::Base
  default from: "jho. <bienvenue@jho.fr>"

  def send_userdata(filename, address)
    time = Time.now.strftime("%Y%m%d_%H%M")
    subject = "jho user data #{time}"
    attachments["userdata_#{time}.zip"] = File.read(filename)
    mail(to: address, subject: subject)
  end
end
