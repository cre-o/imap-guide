class Location < ActiveRecord::Base
  has_many :uploads
  belongs_to :user

  validates :lat, presence: true, numericality: true
  validates :lng, presence: true, numericality: true
end
