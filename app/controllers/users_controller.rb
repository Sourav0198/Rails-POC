class UsersController < ApplicationController
  class AuthenticationError < StandardError; end

  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from AuthenticationError, with: :handle_unauthenticated

  before_action :validate_user_params, only: :signup
  before_action :validate_email, only: %i[login forgot_password]

  def signup
    user_by_id = User.get_user_detail_by_email(user_params[:email])
    if user_by_id
      render json: ResponseWrapper.failure({}, 'User with this email already exists', 403),
             status: :unprocessable_entity
    else
      user_by_id = User.new(user_params)
      if user_by_id.save
        render json: ResponseWrapper.success({}, 'User successfully created', 201), status: :created
      else
        render json: ResponseWrapper.failure({}, @user.errors.full_messages, 400), status: :unprocessable_entity
      end
    end
  end

  def login
    user_by_id = User.get_user_detail_by_email(user_params[:email])
    if user_by_id
      if user_by_id.authenticate(params.require(:password))
        token = AuthenticationTokenService.call(user_by_id.id)
        render json: ResponseWrapper.success({ token: }, 'Authentication Success', 200), status: :ok
      else
        render json: ResponseWrapper.failure({}, 'Authentication failed, Wrong Password', 401), status: :unauthorized
      end
    else
      render json: ResponseWrapper.failure({}, 'Authentication failed, Wrong Email', 401), status: :unauthorized
    end
  end

  def forgot_password
    user = User.find_by(email: user_params[:email])
    if user
      user.skip_password_validation = true
      user.generate_password_reset_token
      user.save

      UserMailer.password_reset_email(user).deliver_now

      render json: ResponseWrapper.success({}, 'Password reset email sent', 200), status: :ok
    else
      render json: ResponseWrapper.failure({}, 'User not found', 404), status: :not_found
    end
  end

  def reset_password
    user = User.find_by(password_reset_token: params[:token])
    if params[:new_password].present? && params[:new_password_confirmation].present?
      if user && user.password_reset_sent_at > 1.hour.ago
        user.password = params[:new_password]
        user.password_confirmation = params[:new_password_confirmation]
        if user.valid?
          user.update(password_reset_token: nil, password_reset_sent_at: nil) # Clear the token after reset
          render json: ResponseWrapper.success({}, 'Password reset successful', 200), status: :ok
        else
          render json: ResponseWrapper.failure({}, user.errors.full_messages, 400), status: :unprocessable_entity
        end
      else
        render json: ResponseWrapper.failure({}, 'Invalid or expired token', 400), status: :unprocessable_entity
      end
    else
      render json: ResponseWrapper.failure({}, 'New password and confirm password are required', 400),
             status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def parameter_missing(e)
    render json: ResponseWrapper.failure({}, e.message, 403), status: :unprocessable_entity
    # render json: { error: e.message }, status: :unprocessable_entity
  end

  def handle_unauthenticated
    head :unauthorized
  end

  def validate_user_params
    @user = User.new(user_params)
    puts "===========".inspect
    p @user.errors.full_messages
    return if @user.valid?
    p @user.errors.full_messages


    render json: ResponseWrapper.failure({}, @user.errors.full_messages, 400), status: :unprocessable_entity
  end

  def validate_email
    return if URI::MailTo::EMAIL_REGEXP.match(user_params[:email])

    render json: ResponseWrapper.failure({}, 'Email must be a valid email address', 400),
           status: :unprocessable_entity
  end
 
end
