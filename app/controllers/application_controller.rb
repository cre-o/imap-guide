class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session

  before_action :preload_app
  before_action :preload_uploads
  before_action :preload_pending_uploads

  respond_to :json

  def show
  end

  private

    def preload_app
      @app = {
        user: current_user
      }.to_json
    end

    def preload_uploads
      uploads =
        if current_user
          ActiveModel::ArraySerializer.new(current_user.uploads, each_serializer: UploadSerializer)
        else
          []
        end

      @uploads = {
        uploads: uploads
      }.to_json
    end

    def preload_pending_uploads
      pending_uploads =
        if user_signed_in? && current_user.admin?
          ActiveModel::ArraySerializer.new(Upload.pending, each_serializer: UploadSerializer)
        else
          []
        end

      @pending_uploads = {
        pending_uploads: pending_uploads
      }.to_json
    end


  protected

    def validate_rights
      unless current_user.present?
        render json: { unauthorised: true }, status: :unprocessable_entity
        return false
      end
    end

end
