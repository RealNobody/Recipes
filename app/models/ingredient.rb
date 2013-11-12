class Ingredient < ActiveRecord::Base
  aliased_by :ingredient_aliases,
             index_sort: -> { includes(:ingredient_category).
                 order("ingredient_categories.order, ingredient_categories.name, ingredients.name") }

  belongs_to :measuring_unit
  belongs_to :ingredient_category

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  validates :measuring_unit_id,
            presence: true

  validates :ingredient_category_id,
            presence: true

  validates_presence_of :measuring_unit
  validates_presence_of :ingredient_category
end