# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # SignUp API Tests
  describe 'POST signup' do
    context 'with valid user params' do
      it 'creates a new user' do
        user_params = {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'Password1!',
          password_confirmation: 'Password1!'
        }

        post :signup, params: user_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('User successfully created')
      end
    end

    context 'with invalid user params' do
      it 'returns unprocessable entity status' do
        user_params = {
          first_name: 'John',
          last_name: 'Doe',
          email: 'invalid_email',
          password: 'password',
          password_confirmation: 'password'
        }

        post :signup, params: user_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to include('Email must be a valid email address')
        expect(JSON.parse(response.body)['error']).to include('Password must include at least one capital letter')
        expect(JSON.parse(response.body)['error']).to include('Password must include at least one special character')
      end
      it 'returns password doesnot match' do
        user_params = {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'passworD!',
          password_confirmation: 'passworD@'
        }

        post :signup, params: user_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with an existing email' do
      it 'returns unprocessable entity status' do
        User.create(
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'Password1!',
          password_confirmation: 'Password1!'
        )

        user_params = {
          first_name: 'Jane',
          last_name: 'Smith',
          email: 'john.doe@example.com',
          password: 'Password1!',
          password_confirmation: 'Password1!'
        }

        post :signup, params: user_params

        p response.body
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('User with this email already exists')
      end
    end
  end

  # LOGIN API Tests
  describe 'POST login' do
    let!(:user) do
      p 'let! called in login api'
      User.create(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        password: 'Password1!',
        password_confirmation: 'Password1!'
      )
    end

    context 'with valid login credentials' do
      it 'returns a token' do
        login_params = {
          email: 'john.doe@example.com',
          password: 'Password1!'
        }

        post :login, params: login_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Authentication Success')
        p JSON.parse(response.body)['data'].key?('token')
        p JSON.parse(response.body)['data']['token']
        expect(JSON.parse(response.body)['data'].key?('token')).blank?
        expect(JSON.parse(response.body)['data']).to have_key('token')
        expect(JSON.parse(response.body)['data']['token']).not_to be_nil
      end
    end

    context 'with an incorrect password' do
      it 'returns unauthorized status' do
        login_params = {
          email: 'john.doe@example.com',
          password: 'WrongPassword'
        }

        post :login, params: login_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('Authentication failed, Wrong Password')
      end
    end

    context 'with an incorrect email' do
      it 'returns unauthorized status' do
        login_params = {
          email: 'nonexistent@example.com',
          password: 'Password1!'
        }

        post :login, params: login_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('Authentication failed, Wrong Email')
      end
    end
  end

  # Forget Password test
  describe 'POST #forgot_password' do
    context 'when a user with the provided email exists' do
      let!(:user) do
        p 'let! called in a context'
        User.create(
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'Password1!',
          password_confirmation: 'Password1!'
        )
      end

      it 'sends a password reset email and returns a success response' do
        forgot_password_params = {
          email: 'john.doe@example.com'
        }

        expect { post :forgot_password, params: forgot_password_params }
          .to change { ActionMailer::Base.deliveries.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Password reset email sent')
      end
    end

    context 'when a user with the provided email does not exist' do
      it 'returns not found response' do
        forgot_password_params = {
          email: 'nonexistent@example.com'
        }

        post :forgot_password, params: forgot_password_params

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('User not found')
      end
    end
  end

  # Reset Password Test Cases.
  describe 'GET #reset_password' do
    context 'with a valid and unexpired token' do
      let!(:user) do
        User.create(
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'Password1!',
          password_confirmation: 'Password1!',
          password_reset_token: 'valid_token',
          password_reset_sent_at: Time.now
        )
      end

      it 'resets the password and returns a success response' do
        reset_password_params = {
          token: 'valid_token',
          new_password: 'NewPassword1!',
          new_password_confirmation: 'NewPassword1!'
        }
        post :reset_password, params: reset_password_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Password reset successful')
        user.reload
        expect(user.password_reset_token).to be_nil
        expect(user.password_reset_sent_at).to be_nil
      end

      context 'new password and confirmation password doesnot match' do
        it 'returns an error response' do
          reset_password_params = {
            token: 'valid_token',
            new_password: 'NewPasswordd1!',
            new_password_confirmation: 'NewPasswordd122!'
          }
          post :reset_password, params: reset_password_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
          expect(JSON.parse(response.body)['error']).to include("Password confirmation doesn't match Password")
        end
      end
    end

    context 'with an invalid or expired token' do
      it 'returns an error response' do
        reset_password_params = {
          token: 'invalid_token',
          new_password: 'NewPassword1!',
          new_password_confirmation: 'NewPassword1!'
        }

        post :reset_password, params: reset_password_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('Invalid or expired token')
      end
    end

    context 'without providing new password and confirmation' do
      it 'returns an error response' do
        reset_password_params = {
          token: 'valid_token'
        }
        post :reset_password, params: reset_password_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('Some Error Occurred')
        expect(JSON.parse(response.body)['error']).to eq('New password and confirm password are required')
      end
    end
  end
end
