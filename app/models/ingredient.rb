class Ingredient < ActiveRecord::Base
  attr_accessible :measuring_unit_id, :name, :ingredient_category_id, :prep_instructions, :day_before_prep_instructions

  belongs_to :measuring_unit
  belongs_to :ingredient_category

  has_many :ingredient_aliases, dependent: :delete_all

  default_scope joins(:ingredient_category).order("ingredient_categories.order, ingredient_categories.name, ingredients.name").readonly(false)

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  validates :measuring_unit_id,
            presence: true

  validates :ingredient_category_id,
            presence: true

  validates_presence_of :measuring_unit
  validates_presence_of :ingredient_category

  after_save :create_default_aliases

  validate do
    # alias_name = alias and id is not null
    # alias_name = alias and id != id
    find_alias = Ingredient.find_by_alias(self.name)

    unless (find_alias == nil || find_alias.id == self.id)
      errors.add(:name, I18n.t("activerecord.ingredient.error.already_exists", name: find_alias.name))
    end
  end

  # This is a helper function to find an ingredient by an alias.
  def self.find_by_alias(alias_name)
    find_alias = IngredientAlias.where(alias: alias_name.downcase()).first()
    unless find_alias == nil
      Ingredient.find(find_alias.ingredient_id)
    end
  end

  def add_alias(alias_name)
    alias_name       = alias_name.downcase()
    found_ingredient = Ingredient.find_by_alias(alias_name)

    if (found_ingredient != nil && found_ingredient.id != self.id)
      nil
    else
      alias_list = self.ingredient_aliases.select do |ingredient_alias|
        ingredient_alias.alias == alias_name
      end

      if (alias_list == nil || alias_list.length == 0)
        new_alias = self.ingredient_aliases.build(alias: alias_name)
      else
        alias_list[0]
      end
    end
  end

  protected
  def create_default_aliases
    # I want all measuring units to have their own name and abbreviation as aliases.
    self.add_alias(self.name.singularize()).save!()
    self.add_alias(self.name.pluralize()).save!()
  end
end