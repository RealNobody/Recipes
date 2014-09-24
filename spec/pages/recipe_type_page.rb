require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"
require "pages/recipe_page"

module RecipePages
  class RecipeTypeSection < ItemEditSection
    element :name, "#recipe_type_name"
  end

  class RecipeTypeEditPage < RecipeAppPage
    def populate_hash_values(values)
      recipe_type_tab.click if has_recipe_type_tab?

      recipe_type.name.set(values[:name])
    end

    def validate_hash_values(values)
      expect(recipe_type.name.value).to eq(values[:name])
    end
  end

  class RecipeTypeFullPage < RecipeTypeEditPage
    full_page_for RecipeType
  end

  class RecipeTypeItemPage < RecipeTypeEditPage
    item_page_for RecipeType
  end

  class RecipeTypeScrollingListPage < RecipeAppPage
    scrolling_list_page_for RecipeType
  end

  class RecipeTypeSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for RecipeType, SearchAlias, :search_aliases
  end

  class RecipeTypeSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for RecipeType, SearchAlias, :search_aliases
  end

  class RecipeTypeRecipeChildItemPage < RecipeViewPage
    child_item_page_for RecipeType, Recipe, :recipes
  end

  class RecipeTypeRecipeChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for RecipeType, Recipe, :recipes
  end
end