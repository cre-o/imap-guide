class UploadSerializer < ActiveModel::Serializer
  attributes :id, :src, :preview_src, :title, :description, :state, :w, :h

  has_one :location

  def w
    1000
  end

  def h
    1000
  end

  def title
    object.description.to_s
  end

  def description
    title
  end

  def src
    object.image.url(:large, timestamp: false)
  end

  def thumb_src
    object.image.url(:thumb, timestamp: false)
  end

  def preview_src
    object.image.url(:preview, timestamp: false)
  end
end
