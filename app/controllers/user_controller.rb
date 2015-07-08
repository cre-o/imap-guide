class UserController < ApplicationController

  def uploads
    if current_user && current_user.admin?
      render json: Upload.active, root: false
    else
      render json: current_user.uploads, root: false
    end
  end
end
