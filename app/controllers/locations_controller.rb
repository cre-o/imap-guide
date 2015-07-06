class LocationsController < ApplicationController

  def create
    location = current_user.locations.new lat: location_params[:lat], lng: location_params[:lng]

    if location.save
      # Add update uploads
      if location_params[:uploads].present?

        update_params = { location_id: location }
        # If current user is admin user, we can just mark them as OK
        update_params.merge!(state: Upload.active_state) if current_user.admin?

        current_user.uploads.where(id: location_params[:uploads]).update_all(update_params)
      end

      render json: location, status: :created,
        content_type: "text/plain" # internet explorer
    else
      render json: location.errors, status: :unprocessable_entity,
        content_type: "text/plain" # internet explorer
    end
  end

  def index
    # Get list of active uploads and get their location_ids
    uploads_for = Upload.ok.pluck(:location_id)
    render json: Location.find(uploads_for), root: false
  end

  def location_params
    params.require(:location).permit(:lat, :lng, uploads: [])
  end
end
