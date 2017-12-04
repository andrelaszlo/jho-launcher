Prelaunchr::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  if Rails.application.config.started
    root :to => "users#new"
  else
    root :to => "users#placeholder"
  end

  post 'users/create' => 'users#create'
  get 'refer-a-friend' => 'users#refer'
  get 'mentions-legales' => 'users#policy'
  get 'r/:id' => 'users#referral'

  unless Rails.application.config.consider_all_requests_local
    get '*not_found', to: 'users#redirect', :format => false
  end
end
