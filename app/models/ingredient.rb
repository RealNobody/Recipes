class Ingredient < ActiveRecord::Base
  attr_accessible :measuring_unit_id, :name, :ingredient_category_id, :prep_instructions, :day_before_prep_instructions

  belongs_to :measuring_unit
  belongs_to :ingredient_category

  default_scope joins(:ingredient_category).order("ingredient_category.order, ingredient_category.name, ingredient.name").readonly(false)

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