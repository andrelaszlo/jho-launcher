require 'users_helper'

class User < ActiveRecord::Base
  belongs_to :referrer, class_name: 'User', foreign_key: 'referrer_id'
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'

  validates :email, presence: true, uniqueness: true, format: {
    with: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i,
    message: 'Invalid email format.'
  }
  validates :referral_code, uniqueness: true

  before_create :create_referral_code
  after_create :send_welcome_email

  def referral_count
    self.referrals.count
  end

  def active_at
    self.referrals.map{ |x| x.created_at }.max or self.created_at
  end

  def total_referrals
    total = self.referrals.count
    self.referrals.each do |ref|
      puts ref.id
      total += ref.total_referrals
    end
    total
  end

  private

  def create_referral_code
    self.referral_code = UsersHelper.unused_referral_code
  end

  def send_welcome_email
    UserMailer.delay.signup_email(self)
  end
end
