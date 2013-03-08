class IngredientCategory < ActiveRecord::Base
  attr_accessible :name, :order

  default_scope order("ingredient_categories.order, name")

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end