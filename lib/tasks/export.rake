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

        headers = ['email', 'direct referrals', 'total referrals', 'registered', 'active', 'referrer', 'referred emails']

        CSV.open(filename, "wb", {headers: headers, write_headers: true}) do |csv|
          User.all.each { |user|
            created = user.created_at.in_time_zone('CET').strftime("%Y-%m-%d %H:%M:%S")
            active = user.active_at.in_time_zone('CET').strftime("%Y-%m-%d %H:%M:%S")
            referred_emails = user.referrals.map { |ref| ref.email }.join ","
            referrer_email = user.referrer ? user.referrer.email : nil
            csv << [user.email, user.referral_count, user.total_referrals, created, active, referrer_email, referred_emails]
            sleep 0.1 # XXX: The above is apparently a bit heavy, relax a little
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
