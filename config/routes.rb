# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  scope 'users', as: :users do
    controller :users do
      post :signup
      post :login
      post :forgot_password
      post :reset_password
    end
  end

  scope 'profile', as: :profile do
    controller :profile do
      get :view
      post :change_password
      put :update_profile
    end
  end
end
