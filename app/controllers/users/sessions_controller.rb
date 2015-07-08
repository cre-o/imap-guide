class Users::SessionsController < Devise::SessionsController
  respond_to :html, only: 'none'

  before_action :guest_or_current, only: :create
  skip_before_action :verify_authenticity_token

  def guest_or_current
    if current_user && current_user.guest?
      session[:guest_user_id] = nil
      sign_out resource_name
    end
  end
end
