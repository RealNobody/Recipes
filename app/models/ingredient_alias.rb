class IngredientAlias < ActiveRecord::Base
  attr_accessible :alias, :ingredient_id

  belongs_to :ingredient

  default_scope joins(:ingredient).readonly(false).order("ingredients.name, alias")

  validates :ingredient_id, presence: true
  validates_presence_of :ingredient

  validates :alias,
            presence:   true,
            length:     { minimum: 1, maximum: 255 },
            uniqueness: { case_sensitive: false }

  def alias
    self[:alias]
  end

  def alias=(alias_name)
    if (alias_name)
      self[:alias] = alias_name.downcase()
    else
      self[:alias] = alias_name
    end
  end

  def list_name
    I18n.t("activerecord.ingredient_alias.list_name", alias: self.alias, ingredient: self.ingredient.name)
  end
end