class UserController < ApplicationController

  def uploads
    render json: current_user.uploads, root: false
  end
end
