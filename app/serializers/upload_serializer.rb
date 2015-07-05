class UploadSerializer < ActiveModel::Serializer
  attributes :id, :src, :preview_src, :description, :state

  has_one :location

  # def location
  #   object.location
  # end

  def description
    object.description.to_s
  end

  def src
    # ActionController::Base.helpers.image_path
    object.image.url(:original, timestamp: false)
  end

  def thumb_src
    object.image.url(:thumb, timestamp: false)
  end

  def preview_src
    object.image.url(:preview, timestamp: false)
  end
end
