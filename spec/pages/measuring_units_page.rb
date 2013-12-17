require "pages/scrolling_list_section"
require "pages/recipe_page"

class MeasuringUnitsSection < SitePrism::Section
  element :name, "#measuring_unit_name"
  element :has_abbreviation, "#measuring_unit_has_abbreviation"
  element :abbreviation, "#measuring_unit_abbreviation"
  element :save, "input[name=commit]"

  def populate_hash_values(values)
    measuring_unit.has_abbreviation.set(!!values[:abbreviation])
    measuring_unit.name.set(values[:name])
    measuring_unit.abbreviation.set(values[:abbreviation])
  end
end

class MeasuringUnitsItemPage < RecipePage
  set_url         "/measuring_units/item{/item_id}{/edit}{?query*}"
  set_url_matcher /\/measuring_units\/item(:?(:?\/(:?\d+|new))(:?\/edit)?)?(:?\?.*)?/

  section :measuring_unit, MeasuringUnitsSection, "#measuring_unit"
end

class MeasuringUnitsPage < RecipePage
  set_url         "/measuring_units{/item_id}{/edit}{?query*}"
  set_url_matcher /\/measuring_units(:?(:?\/(:?\d+|new))(:?\/edit)?)?(:?\?.*)?/

  section :index_list, ScrollingListSection, "#scroll-measuring_units .scrolling-list-content"
  section :measuring_unit, MeasuringUnitsSection, "#measuring_unit"
end