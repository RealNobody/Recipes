class PrepOrder < ActiveRecord::Base
  attr_accessible :name, :order

  has_many :recipes

  #default_scope order("prep_orders.order, name")
  scope :index_sort, order("prep_orders.order, name")

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end