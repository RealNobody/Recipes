class IngredientCategory < ActiveRecord::Base
  attr_accessible :name, :order

  has_many :ingredients

  #default_scope order("ingredient_categories.order, name")
  scope :index_sort, order("ingredient_categories.order, name")

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end