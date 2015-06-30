class UsersController < ApplicationController

  def authenticated
    render json: (current_user ? true : false)
  end

end
