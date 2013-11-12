class IngredientCategory < ActiveRecord::Base
  has_many :ingredients

  scope :index_sort, -> { order("ingredient_categories.order, name") }

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end