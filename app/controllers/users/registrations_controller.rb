class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, only: 'none'
end
