class LocationsController < ApplicationController

  def create
    location = current_user.locations.new lat: location_params[:lat], lng: location_params[:lng]
    #location.uploads = params[:description]

    if location.save
      # Add update uploads
      if location_params[:uploads].present?
        current_user.uploads.where(id: location_params[:uploads])
        .update_all(location_id: location)
      end

      render json: location, status: :created,
        content_type: "text/plain" # internet explorer
    else
      render json: location.errors, status: :unprocessable_entity,
        content_type: "text/plain" # internet explorer
    end
  end

  def index
    render json: Location.all.limit(5), root: false
  end

  def location_params
    params.require(:location).permit(:lat, :lng, uploads: [])
  end
end
