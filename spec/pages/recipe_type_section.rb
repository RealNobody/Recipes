require "pages/item_edit_section"

class RecipeTypeSection < ItemEditSection
  element :name, "#recipe_type_name"

  def populate_hash_values(values)
    name.set(values[:name])
  end
end