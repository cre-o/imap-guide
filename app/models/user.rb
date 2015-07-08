class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :locations
  has_many :uploads, dependent: :destroy
  belongs_to :role

  def admin?
    role.name == 'admin'
  end

  def guest?
    name == 'guest'
  end
end
