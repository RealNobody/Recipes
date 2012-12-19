class User < ActiveRecord::Base
  attr_accessible :email, :name, :password

  validates :email, length: { maximum: 255 }
  validates :email, length: { maximum: 255 }
  validates :email, length: { maximum: 255 }
end
