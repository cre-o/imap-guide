class Location < ActiveRecord::Base
  has_many :uploads
  belongs_to :user
end
