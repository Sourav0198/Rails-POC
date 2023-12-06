class ProfileController < ApplicationController
    class AuthenticationError < StandardError; end

  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from AuthenticationError, with: :handle_unauthenticated
  # rescue_from JWT::VerificationError, with: :handle_unauthenticated

  before_action :authenticate_user, only: %i[view change_password update_profile]

  def view
    user = User.find_by_id(current_user_id)
    p ' hello '
    render json: ResponseWrapper.success(user, 'Success', 201), status: :created
  end

  def change_password
    password_params = confirm_password_params

    unless @user.authenticate(password_params[:current_password])
      return render json: ResponseWrapper.failure('Current password is incorrect', 422), status: :unprocessable_entity
    end

    if password_params[:password] != password_params[:new_password]
      return render json: ResponseWrapper.failure("New password and confirm password don't match", 422),
                    status: :unprocessable_entity
    end

    @user.password = password_params[:password]

    if @user.valid?
      @user.save
      render json: ResponseWrapper.success(@user, 'Password changed successfully', 200), status: :ok
    else
      render json: ResponseWrapper.failure(@user.errors.full_messages, 'Validation failed', 422),
             status: :unprocessable_entity
    end
  end

  def update_profile
    @user = User.find_by_id(params[:id])

    if @user
      if @user.update(user_params)
        render json: ResponseWrapper.success(@user, 'User is updated', 200), status: :ok
      else
        render json: ResponseWrapper.failure(@user.errors, 'Validation failed', 422), status: :unprocessable_entity
      end
    else
      render json: ResponseWrapper.failure({}, 'User not found', 404), status: :not_found
    end
  end

  private

  def confirm_password_params
    current_user_id = authenticate_user
    @user = User.find_by_id(current_user_id)
    params.permit(:current_password, :password, :new_password)
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password_digest)
  end

  def parameter_missing(e)
    render json: ResponseWrapper.failure({}, e.message, 422), status: :unprocessable_entity
  end

  def handle_unauthenticated(error_message = 'Authentication Unsuccessful')
    # head :unauthorized
    render json: { message: error_message, status: 'Unauthorized' }, status: :unauthorized
  end

  def authenticate_user
    token = request.headers['Authorization']&.split(' ')&.last
    begin
      raise AuthenticationError unless token && AuthenticationTokenService.decode(token)

      # The token is valid, extract the user ID and store it in current_user_id
      @current_user_id = AuthenticationTokenService.decode(token)

    # The token is invalid or missing, raise an AuthenticationError
    rescue JWT::VerificationError => e
      # This block will be executed when either exception occurs
      handle_unauthenticated(e.message)
    end
  end

  attr_reader :current_user_id
end
