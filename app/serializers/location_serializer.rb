class LocationSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lng, :uploads_size, :last_upload_src

  def uploads_size
    object.uploads.size
  end

  def last_upload_src
    object.uploads.last.image.url(:thumb)
  end
end
