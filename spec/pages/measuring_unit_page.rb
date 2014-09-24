require "pages/item_edit_section"
require "pages/search_alias_page"
require "pages/recipe_app_page"

module RecipePages
  class MeasuringUnitShowSection < ItemEditSection
    element :name, "#measuring_unit_name"
    element :has_abbreviation, "#measuring_unit_has_abbreviation"
    element :abbreviation, "#measuring_unit_abbreviation"
  end

  class MeasuringUnitSection < MeasuringUnitShowSection
    # element :name, "#measuring_unit_name"
    # element :has_abbreviation, "#measuring_unit_has_abbreviation"
    # element :abbreviation, "#measuring_unit_abbreviation"
  end

  class MeasuringUnitEditPage < RecipeAppPage
    def populate_hash_values(values)
      measuring_unit_tab.click if has_measuring_unit_tab?

      measuring_unit.has_abbreviation.set(!!values[:abbreviation])
      measuring_unit.name.set(values[:name])
      measuring_unit.abbreviation.set(values[:abbreviation])
    end

    def validate_hash_values(values)
      expect(measuring_unit.has_abbreviation.checked?).to eq(!!values[:abbreviation])
      expect(measuring_unit.name.value).to eq(values[:name])
      expect(measuring_unit.abbreviation.value).to eq(values[:abbreviation])
    end
  end

  class MeasuringUnitViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(has_abbreviation.checked?).to eq(!!values[:abbreviation])
      expect(name.text).to eq(values[:name])
      expect(abbreviation.text).to eq(values[:abbreviation])
    end
  end

  def measuring_unit_page
    element :search_aliases_tab, "#search_aliases_tab"
  end

  class MeasuringUnitFullPage < MeasuringUnitEditPage
    full_page_for MeasuringUnit
  end

  class MeasuringUnitItemPage < MeasuringUnitEditPage
    item_page_for MeasuringUnit
  end

  class MeasuringUnitScrollingListPage < RecipeAppPage
    scrolling_list_page_for MeasuringUnit
  end

  class MeasuringUnitSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for MeasuringUnit, SearchAlias, :search_aliases
  end

  class MeasuringUnitSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, SearchAlias, :search_aliases
  end

  class MeasuringUnitIngredientChildItemPage < IngredientViewPage
    child_item_page_for MeasuringUnit, Ingredient, :ingredients
  end

  class MeasuringUnitIngredientChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, Ingredient, :ingredients
  end

  class MeasuringUnitLargerMeasurementConversionChildItemPage < MeasurementConversionViewPage
    child_item_page_for MeasuringUnit, MeasurementConversion, :larger_measurement_conversions
  end

  class MeasuringUnitLargerMeasurementConversionChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, MeasurementConversion, :larger_measurement_conversions
  end

  class MeasuringUnitSmallerMeasurementConversionChildItemPage < MeasurementConversionViewPage
    child_item_page_for MeasuringUnit, MeasurementConversion, :smaller_measurement_conversions
  end

  class MeasuringUnitSmallerMeasurementConversionChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, MeasurementConversion, :smaller_measurement_conversions
  end

  class MeasuringUnitLargerMeasuringUnitChildItemPage < MeasuringUnitViewPage
    child_item_page_for MeasuringUnit, MeasuringUnit, :larger_measuring_units
  end

  class MeasuringUnitLargerMeasuringUnitChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, MeasuringUnit, :larger_measuring_units
  end

  class MeasuringUnitSmallerMeasuringUnitChildItemPage < MeasuringUnitViewPage
    child_item_page_for MeasuringUnit, MeasuringUnit, :smaller_measuring_units
  end

  class MeasuringUnitSmallerMeasuringUnitChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasuringUnit, MeasuringUnit, :smaller_measuring_units
  end
end