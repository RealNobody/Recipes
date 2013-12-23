require "pages/pick_dialog_section"
require "pages/item_edit_section"

class MeasurementConversionSection < ItemEditSection
  element :multiplier, "#measurement_conversion_day_before_prep_instructions"

  element :smaller_measuring_unit, "#link_ingredient_smaller_measuring_unit_id"
  element :pick_smaller_measuring_unit, "#pick_ingredient_smaller_measuring_unit_id"
  section :pick_dialog_smaller_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"

  element :larger_measuring_unit, "#link_ingredient_larger_measuring_unit_id"
  element :pick_larger_measuring_unit, "#pick_ingredient_larger_measuring_unit_id"
  section :pick_dialog_larger_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"

  def populate_hash_values(values)
    multiplier.set(values[:multiplier])

    pick_item(self, values, :ingredient, :measuring_unit, :smaller_measuring_unit)
    pick_item(self, values, :ingredient, :measuring_unit, :larger_measuring_unit)
  end
end