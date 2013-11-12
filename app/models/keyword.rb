class Keyword < ActiveRecord::Base
  aliased_by :keyword_aliases

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end