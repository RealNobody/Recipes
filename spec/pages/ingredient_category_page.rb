require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"
require "pages/ingredient_page"

module RecipePages
  class IngredientCategorySection < ItemEditSection
    element :name, "#ingredient_category_name"
    element :order, "#ingredient_category_order"
  end

  class IngredientCategoryEditPage < RecipeAppPage
    def populate_hash_values(values)
      ingredient_category_tab.click if has_ingredient_category_tab?

      ingredient_category.name.set(values[:name])
      ingredient_category.order.set(values[:order])
    end

    def validate_hash_values(values)
      expect(ingredient_category.name.value).to eq(values[:name])
      expect(ingredient_category.order.value).to eq(values[:order])
    end
  end

  class IngredientCategoryFullPage < IngredientCategoryEditPage
    full_page_for IngredientCategory
  end

  class IngredientCategoryItemPage < IngredientCategoryEditPage
    item_page_for IngredientCategory
  end

  class IngredientCategoryScrollingListPage < RecipeAppPage
    scrolling_list_page_for IngredientCategory
  end

  class IngredientCategorySearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for IngredientCategory, SearchAlias, :search_aliases
  end

  class IngredientCategorySearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for IngredientCategory, SearchAlias, :search_aliases
  end

  class IngredientCategoryIngredientChildItemPage < IngredientViewPage
    child_item_page_for IngredientCategory, Ingredient, :ingredients
  end

  class IngredientCategoryIngredientChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for IngredientCategory, Ingredient, :ingredients
  end
end