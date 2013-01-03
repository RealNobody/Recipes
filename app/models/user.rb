# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer(4)      default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#

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