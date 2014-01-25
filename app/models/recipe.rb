class Recipe < ActiveRecord::Base
  aliased

  belongs_to :recipe_type
  belongs_to :prep_order

  scope :index_sort, -> { order(:name) }

  validates :name,
            presence: true,
            length:   { minimum: 1, maximum: 255 }

  validates :label_instructions,
            length: { maximum: 255 }

  validates :prep_order_id,
            presence: true

  validates :recipe_type_id,
            presence: true

  validates_presence_of :prep_order
  validates_presence_of :recipe_type

  validates :servings,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :meals,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate do
    # Either the cooking_instructions or the prep_instructions must have data.
    if self[:cooking_instructions].blank? && self[:prep_instructions].blank?
      errors.add(:cooking_instructions, I18n.t("activerecord.recipe.error.blank_instructions"))
    end
  end
end