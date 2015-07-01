class UserController < ApplicationController
  before_action :validate_rights, only: [:uploads]


  def uploads
    render json: current_user.uploads, root: false
  end

end
