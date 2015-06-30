Rails.application.routes.draw do

  root to: 'application#show'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  resource :map, only: :show
  resources :locations
  resources :uploads, only: :create

  get '/users/authenticated'

end
