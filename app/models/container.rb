class Container < ActiveRecord::Base
  aliased

  has_and_belongs_to_many :recipes

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end