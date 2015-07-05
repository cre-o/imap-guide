Rails.application.routes.draw do

  root to: 'application#show'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  resources :uploads, only: [:index, :create, :destroy] do
    collection { get 'pending' }
  end

  resources :locations do
    root to: :index

    resources :uploads, only: [:index, :show]
  end

  get '/user/uploads'
end
