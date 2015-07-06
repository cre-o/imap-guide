class Upload < ActiveRecord::Base
  ALLOWED_CONTENT_TYPES = %w(image/jpeg image/png image/gif)
  STATES = %w(pending ok)

  belongs_to :location
  belongs_to :user

  has_attached_file :image, styles: { thumb: "46x46#", preview: "310x310#" },
    default_url: "/images/:style/missing.png"

  validates_attachment :image, presence: true,
      :size => { in: 2.kilobytes..800.kilobytes },
      :content_type => { content_type: ALLOWED_CONTENT_TYPES }

  validates :description, length: { maximum: 300 }

  default_scope { order(updated_at: :desc) }

  scope :ok, -> { where(state: 'ok') }
  scope :active, -> { where(state: 'ok') }
  scope :pending, -> { where(state: 'pending') }
  scope :with_location, -> { where.not(location_id: nil) }

  def info
    {
      id: read_attribute(:id),
      name: read_attribute(:upload_file_name),
      type: read_attribute(:upload_content_type),
      size: read_attribute(:upload_file_size),
      url:  image.url(:original),
      thumbnail_url: image.url(:thumb)
    }
  end

  state_machine :state, initial: :pending do
    event :approve do
      transition pending: :ok
    end
  end

  class << self
    def default_state
      'pending'
    end

    def active_state
      'ok'
    end
  end
end
