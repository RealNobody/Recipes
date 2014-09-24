require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"
require "pages/recipe_page"

module RecipePages
  class PrepOrderSection < ItemEditSection
    element :name, "#prep_order_name"
    element :order, "#prep_order_order"
  end

  class PrepOrderEditPage < RecipeAppPage
    def populate_hash_values(values)
      pre_order_tab.click if has_pre_order_tab?

      pre_order.name.set(values[:name])
      pre_order.order.set(values[:order])
    end

    def validate_hash_values(values)
      expect(pre_order.name.value).to eq(values[:name])
      expect(pre_order.order.value).to eq(values[:order])
    end
  end

  class PrepOrderFullPage < PrepOrderEditPage
    full_page_for PrepOrder
  end

  class PrepOrderItemPage < PrepOrderEditPage
    item_page_for PrepOrder
  end

  class PrepOrderScrollingListPage < RecipeAppPage
    scrolling_list_page_for PrepOrder
  end

  class PrepOrderSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for PrepOrder, SearchAlias, :search_aliases
  end

  class PrepOrderSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for PrepOrder, SearchAlias, :search_aliases
  end

  class PrepOrderRecipeChildItemPage < RecipeViewPage
    child_item_page_for PrepOrder, Recipe, :recipes
  end

  class PrepOrderRecipeChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for PrepOrder, Recipe, :recipes
  end
end