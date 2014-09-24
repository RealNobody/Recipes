require "pages/pick_dialog_section"
require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"

module RecipePages
  class IngredientShowSection < ItemEditSection
    element :name, "#ingredient_category_name"
    element :prep_instructions, "#ingredient_category_prep_instructions"
    element :day_before_prep_instructions, "#ingredient_category_day_before_prep_instructions"
    element :measuring_unit, "#link_ingredient_measuring_unit_id"
    element :ingredient_category, "#link_ingredient_ingredient_category_id"
  end

  class IngredientSection < IngredientShowSection
    # element :name, "#ingredient_category_name"
    # element :prep_instructions, "#ingredient_category_prep_instructions"
    # element :day_before_prep_instructions, "#ingredient_category_day_before_prep_instructions"

    # element :measuring_unit, "#link_ingredient_measuring_unit_id"
    element :pick_measuring_unit, "#pick_ingredient_measuring_unit_id"
    section :pick_dialog_measuring_unit, PickDialogSection, "#pick-scroll-measuring_unit"

    # element :ingredient_category, "#link_ingredient_ingredient_category_id"
    element :pick_ingredient_category, "#pick_ingredient_ingredient_category_id"
    section :pick_dialog_ingredient_category, PickDialogSection, "#pick-scroll-ingredient_category"
  end

  class IngredientEditPage < RecipeAppPage
    def populate_hash_values(values)
      ingredient_tab.click if has_ingredient_tab?

      ingredient.name.set(values[:name])
      ingredient.prep_instructions.set(values[:prep_instructions])
      ingredient.day_before_prep_instructions.set(values[:day_before_prep_instructions])

      pick_item(ingredient, values, :ingredient, :ingredient_category)
      pick_item(ingredient, values, :ingredient, :measuring_unit)
    end

    def validate_hash_values(values)
      expect(ingredient.name.value).to eq(values[:name])
      expect(ingredient.prep_instructions.value).to eq(values[:prep_instructions])
      expect(ingredient.day_before_prep_instructions.value).to eq(values[:day_before_prep_instructions])

      expect(ingredient.ingredient_category[:href]).to eq("/ingredient_categories/#{values[:ingredient_category_id]}")
      expect(ingredient.ingredient_category[:href]).to eq("/measuring_units/#{values[:measuring_unit_id]}")
    end
  end

  class IngredientViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(name.value).to eq(values[:name])
      expect(prep_instructions.value).to eq(values[:prep_instructions])
      expect(day_before_prep_instructions.value).to eq(values[:day_before_prep_instructions])

      expect(ingredient_category[:href]).to eq("/ingredient_categories/#{values[:ingredient_category_id]}")
      expect(ingredient_category[:href]).to eq("/measuring_units/#{values[:measuring_unit_id]}")
    end
  end

  class IngredientFullPage < IngredientEditPage
    full_page_for Ingredient
  end

  class IngredientItemPage < IngredientEditPage
    item_page_for Ingredient
  end

  class IngredientScrollingListPage < RecipeAppPage
    scrolling_list_page_for Ingredient
  end

  class IngredientSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for Ingredient, SearchAlias, :search_aliases
  end

  class IngredientSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Ingredient, SearchAlias, :search_aliases
  end
end