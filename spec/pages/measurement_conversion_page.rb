require "pages/pick_dialog_section"
require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"

module RecipePages
  class MeasurementConversionShowSection < ItemEditSection
    element :multiplier, "#measurement_conversion_day_before_prep_instructions"
    element :smaller_measuring_unit, "#link_ingredient_smaller_measuring_unit_id"
    element :larger_measuring_unit, "#link_ingredient_larger_measuring_unit_id"
  end

  class MeasurementConversionSection < MeasurementConversionShowSection
    # element :multiplier, "#measurement_conversion_day_before_prep_instructions"

    # element :smaller_measuring_unit, "#link_ingredient_smaller_measuring_unit_id"
    element :pick_smaller_measuring_unit, "#pick_ingredient_smaller_measuring_unit_id"
    section :pick_dialog_smaller_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"

    # element :larger_measuring_unit, "#link_ingredient_larger_measuring_unit_id"
    element :pick_larger_measuring_unit, "#pick_ingredient_larger_measuring_unit_id"
    section :pick_dialog_larger_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"
  end

  class MeasurementConversionEditPage < RecipeAppPage
    def populate_hash_values(values)
      measurement_conversion_tab.click if has_measurement_conversion_tab?

      measurement_conversion.multiplier.set(values[:multiplier])

      pick_item(measurement_conversion, values, :ingredient, :measuring_unit, :smaller_measuring_unit)
      pick_item(measurement_conversion, values, :ingredient, :measuring_unit, :larger_measuring_unit)
    end

    def validate_hash_values(values)
      expect(measurement_conversion.multiplier.value).to eq(value[:multiplier])
      expect(measurement_conversion.smaller_measuring_unit[:href]).to eq("/measuring_units/#{values[:smaller_measuring_unit_id]}")
      expect(measurement_conversion.larger_measuring_unit[:href]).to eq("/measuring_units/#{values[:larger_measuring_unit_id]}")
    end
  end

  class MeasurementConversionViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(multiplier.text).to eq(value[:multiplier])
      expect(smaller_measuring_unit[:href]).to eq("/measuring_units/#{values[:smaller_measuring_unit_id]}")
      expect(larger_measuring_unit[:href]).to eq("/measuring_units/#{values[:larger_measuring_unit_id]}")
    end
  end

  class MeasurementConversionFullPage < MeasurementConversionEditPage
    full_page_for MeasurementConversion
  end

  class MeasurementConversionItemPage < MeasurementConversionEditPage
    item_page_for MeasurementConversion
  end

  class MeasurementConversionScrollingListPage < RecipeAppPage
    scrolling_list_page_for MeasurementConversion
  end

  class MeasurementConversionSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for MeasurementConversion, SearchAlias, :search_aliases
  end

  class MeasurementConversionSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for MeasurementConversion, SearchAlias, :search_aliases
  end
end