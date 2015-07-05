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

  def destroy
    upload = current_user.uploads.find(params[:id])

    if upload.destroy
      render json: { id: params[:id] }, status: :ok
    else
      render json: { fail: 'something wrong' }, status: :unprocessable_entity
    end
  end

  def pending
    if current_user.admin?
      render json: Upload.pending, status: :ok
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  def index
    uploads = params[:location_id].present?? Upload.active.where(location_id: params[:location_id]) : Upload.active
    render json: uploads
  end

  private

    def location_params
      params.require(:location_id)
    end

    def upload_params
      params.require(:upload).permit(:id, :image, :location_id)
    end

end
