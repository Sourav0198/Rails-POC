# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset_email(user)
    @user = user
    @reset_token = user.password_reset_token
    mail(to: user.email, subject: 'Reset Your Password')
  end
end
