class Users::SessionsController < Devise::SessionsController
  respond_to :json
  respond_to :html, only: 'none'
end
