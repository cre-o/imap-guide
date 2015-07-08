Rails.application.routes.draw do

  root to: 'application#show'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  resources :uploads, only: [:index, :create, :destroy, :update] do
    collection { get 'pending' }
    put 'approve'
  end

  resources :locations do
    root action: :index

    resources :uploads, only: [:index, :show]
  end

  get '/user/uploads'
end
