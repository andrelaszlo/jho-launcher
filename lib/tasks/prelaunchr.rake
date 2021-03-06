require 'csv'

namespace :prelaunchr do
    desc "Will out put CSV's for each group of users you should email"
    task :create_winner_csvs => :environment do
        stops = [5, 10, 25, 50]

        winners = Hash.new {|h,k| h[k]=[]} 
        User.all.each { |user|
            found = nil

            stops.reverse_each { |stop|
                if stop <= user.referrals.count and !found
                    found = stop
                end
            }

            if found
                winners[found] << user
            end
        }

        winners.each { |stop, list|
            filename = "#{Rails.root}/lib/assets/group_#{stop}.csv"
            puts "Outputting #{filename}"
            CSV.open(filename, "wb") do |csv|
                list.each { |user|  
                    csv << [user.email, user.referrals.count]
                }
            end
        }
    end
end
