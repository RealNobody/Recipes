require "pages/item_edit_section"

class MeasuringUnitSection < ItemEditSection
  element :name, "#measuring_unit_name"
  element :has_abbreviation, "#measuring_unit_has_abbreviation"
  element :abbreviation, "#measuring_unit_abbreviation"

  def populate_hash_values(values)
    has_abbreviation.set(!!values[:abbreviation])
    name.set(values[:name])
    abbreviation.set(values[:abbreviation])
  end
end