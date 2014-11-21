class Keyword < ActiveRecord::Base
  aliased

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end