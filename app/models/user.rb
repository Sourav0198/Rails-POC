# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  attr_accessor :skip_password_validation

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be a valid email address' }
  validates :password, presence: true, length: { minimum: 8, message: 'must be at least 8 characters long' },
                       if: :password_changed?
  validates :password, format: { with: /[A-Z]/, message: 'must include at least one capital letter' },
                       if: :password_changed?
  validates :password, format: { with: /[!@#$%^&*]/, message: 'must include at least one special character' },
                       if: :password_changed?
  validates :first_name, presence: true, length: { in: 2..30, message: 'must be 2 to 30 characters long' }
  validates :last_name, presence: true, length: { in: 2..30, message: 'must be 2 to 30 characters long' }

  def self.get_user_detail_by_email(email)
    User.find_by(email:)
  end

  def generate_password_reset_token
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.now
    save(validate: !skip_password_validation)
  end

  def password_changed?
    password.present? || password_digest.blank?
  end
end
