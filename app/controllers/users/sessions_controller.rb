class Users::SessionsController < Devise::SessionsController
  respond_to :html, only: 'none'
end
