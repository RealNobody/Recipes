class PrepOrder < ActiveRecord::Base
  has_many :recipes

  scope :index_sort, -> { order("prep_orders.order, name") }

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end