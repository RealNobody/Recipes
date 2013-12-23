require "pages/item_edit_section"

class IngredientCategorySection < ItemEditSection
  element :name, "#ingredient_category_name"
  element :order, "#ingredient_category_order"

  def populate_hash_values(values)
    name.set(values[:name])
    order.set(values[:order])
  end
end