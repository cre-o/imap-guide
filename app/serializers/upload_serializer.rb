class UploadSerializer < ActiveModel::Serializer
  attributes :id, :src, :preview_src, :title, :description, :state, :w, :h

  has_one :location

  def w
    512
  end

  def h
    512
  end

  # Used in gallery
  def title
    if object.location_id.present?
      "#{description}
      <div class='location'>#{location_time(object.location.lat,'N')}, #{location_time(object.location.lng, 'E')}</div>"
    else
      description
    end
  end

  def location_time(deg, pos = 'N')
    d  = deg.to_i
    md = (deg - d).abs * 60
    m  = md.to_i
    sd = (md - m) * 60
    "#{d}°#{m}'#{sd}\"#{pos}"
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
