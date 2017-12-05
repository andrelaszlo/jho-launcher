require 'zip'
require 'fileutils'

namespace :export do
  desc "Email CSV with users and referral count to an administrator"
  task userdata: :environment do
    userdata_email = ENV['USERDATA_EMAIL']
    if userdata_email.nil?
      puts "No USERDATA_EMAIL address set"
    else
      begin
        filename = "#{Rails.root}/lib/assets/email_output.csv"
        zipfilename = "#{Rails.root}/lib/assets/email_output.zip"

        CSV.open(filename, "wb") do |csv|
          User.all.each { |user|
            csv << [user.email, user.referrals.count]
          }
        end

        Zip::File.open(zipfilename, Zip::File::CREATE) { |zipfile|
          zipfile.add 'userdata.csv', filename
        }

        UserdataMailer.send_userdata(zipfilename, userdata_email).deliver_now
      rescue Exception => ex
        puts "#{ex}"
        puts ex.backtrace
      ensure
        # Clean up
        FileUtils.rm filename, :force => true
        FileUtils.rm zipfilename, :force => true
      end
    end
  end

end
