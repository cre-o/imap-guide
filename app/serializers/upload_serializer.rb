class UploadSerializer < ActiveModel::Serializer
  attributes :id, :big_src, :thumb_src, :description, :state

  has_one :location

  # def location
  #   object.location
  # end

  def description
    object.description.to_s
  end

  def big_src
    # ActionController::Base.helpers.image_path
    object.image.url(:original, timestamp: false)
  end

  def thumb_src
    # ActionController::Base.helpers.image_path
    object.image.url(:medium, timestamp: false)
  end
end
