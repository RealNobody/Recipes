class Container < ActiveRecord::Base
  aliased_by :container_aliases

  attr_accessible :name

  #default_scope order(:name)
  scope :index_sort, order(:name)

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end