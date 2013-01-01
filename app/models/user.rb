class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
          # :registerable,
          :recoverable,
          :rememberable,
          :trackable,
          :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email,
                  :name,
                  :password,
                  :password_confirmation,
                  :remember_me

  # has_secure_password

  validates :email,
            length:     { maximum: 255 },
            presence:   true,
            uniqueness: { case_sensitive: false }

  validates :name,
            length:     { maximum: 255 },
            presence:   true,
            uniqueness: { case_sensitive: false }

  validates :password,
            length:     { maximum: 255, minimum: 5 },
            presence:   true
end