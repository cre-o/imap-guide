class UploadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :approve]

  def approve
    if current_user && current_user.admin?

      upload = Upload.find_by(id: params[:upload_id])

      if upload && upload.approve!
        render nothing: true, status: :ok
      else
        render nothing: true, status: :gone
      end
    else
      render nothing: true, status: :unauthorized
    end
  end

  def create
    upload = current_user.uploads.new(upload_params)
    upload.description = params[:description]

    if upload.save
      render json: { id: upload.id }, status: :created,
        content_type: "text/plain" # internet explorer
    else
      render json: { errors: upload.errors }, status: :unprocessable_entity,
        content_type: "text/plain" # internet explorer
    end
  end

  def destroy
    if current_user.admin?
      # admin can destroy whatever uploads
      upload = Upload.find(params[:id])
    else
      # user can destroy only their uploads
      upload = current_user.uploads.find(params[:id])
    end

    if upload.destroy
      render json: { id: params[:id] }, status: :ok
    else
      render json: { fail: 'something wrong' }, status: :unprocessable_entity
    end
  end

  def pending
    if current_user.admin?
      render json: Upload.pending, root: false, status: :ok
    else
      render nothing: true, status: :unauthorized
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
