class Container < ActiveRecord::Base
  attr_accessible :name

  default_scope order(:name)

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end