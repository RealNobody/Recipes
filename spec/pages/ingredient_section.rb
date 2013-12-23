require "pages/pick_dialog_section"
require "pages/item_edit_section"

class IngredientSection < ItemEditSection
  element :name, "#ingredient_category_name"
  element :prep_instructions, "#ingredient_category_prep_instructions"
  element :day_before_prep_instructions, "#ingredient_category_day_before_prep_instructions"

  element :measuring_unit, "#link_ingredient_measuring_unit_id"
  element :pick_measuring_unit, "#pick_ingredient_measuring_unit_id"
  section :pick_dialog_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"

  element :ingredient_category, "#link_ingredient_ingredient_category_id"
  element :pick_ingredient_category, "#pick_ingredient_ingredient_category_id"
  section :pick_dialog_ingredient_category, PickDialogSection, "#pick-scroll-ingredient_category"

  def populate_hash_values(values)
    name.set(values[:name])
    prep_instructions.set(values[:prep_instructions])
    day_before_prep_instructions.set(values[:day_before_prep_instructions])

    pick_item(self, values, :ingredient, :ingredient_category)
    pick_item(self, values, :ingredient, :measuring_unit)
  end
end