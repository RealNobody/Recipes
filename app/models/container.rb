class Container < ActiveRecord::Base
  aliased_by :container_aliases

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end