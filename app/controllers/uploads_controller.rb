class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :validate_rights, only: [:create]

  def create
    upload = current_user.uploads.new(upload_params)
    upload.description = params[:description]

    if upload.save
      render json: upload.info, status: :created,
        content_type: "text/plain" # internet explorer
    else
      render json: upload.errors, status: :unprocessable_entity,
        content_type: "text/plain" # internet explorer
    end
  end

  def index
    render json: Upload.all
  end

  private

    def upload_params
      params.require(:upload).permit(:image)
    end

end
