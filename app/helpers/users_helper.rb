module UsersHelper
  def self.unused_referral_code
    referral_code = UsersHelper.generate_referral_id
    collision = User.find_by_referral_code(referral_code)

    until collision.nil?
      referral_code = UsersHelper.generate_referral_id
      collision = User.find_by_referral_code(referral_code)
    end
    referral_code
  end

  def generate_referral_id(length=6)
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    (0...length).map { o[rand(o.length)] }.join
  end
  module_function :generate_referral_id
end
