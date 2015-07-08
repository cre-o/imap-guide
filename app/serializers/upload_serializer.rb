# encoding: UTF-8
class UploadSerializer < ActiveModel::Serializer
  include ERB::Util

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
      <div class='location js-location'>
      <span> #{location_time(object.location.lat,'N')}, #{location_time(object.location.lng, 'E')} </span>
      <div class='copy' style='display: none'> copy:
        <input type='text' onclick='this.focus();this.select()'
          value='#{location_time(object.location.lat,'N')}, #{location_time(object.location.lng, 'E')}' />
      </div>
      </div>"
    else
      description
    end
  end

  def location_time(deg, pos = 'N')
    d  = deg.to_i
    md = (deg - d).abs * 60
    m  = md.to_i
    sd = (md - m) * 60
    sd = sd.rand(2) # minimize
    html_escape("#{d}°#{m}'#{sd}\"#{pos}")
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
