require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"

module RecipePages
  class ContainerSection < ItemEditSection
    element :name, "#container_name"
  end

  class ContainerEditPage < RecipeAppPage
    def populate_hash_values(values)
      container_tab.click if has_container_tab?
      container.name.set(values[:name])
    end

    def validate_hash_values(values)
      expect(container.name.value).to eq(values[:name])
    end
  end

  class ContainerViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(container.name.text).to eq(values[:name])
    end
  end

  # class ContainerShowSection < ItemEditSection
  #   element :name, "#container_name"
  #
  #   def populate_hash_values(values)
  #   end
  #
  #   def validate_hash_values(values)
  #     expect(name.text).to eq(values[:name])
  #   end
  # end

  class ContainerFullPage < ContainerEditPage
    full_page_for Container
  end

  class ContainerItemPage < ContainerEditPage
    item_page_for Container
  end

  class ContainerScrollingListPage < RecipeAppPage
    scrolling_list_page_for Container
  end

  class ContainerSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for Container, SearchAlias, :search_aliases
  end

  class ContainerSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Container, SearchAlias, :search_aliases
  end

  # class ContainerRecipeChildItemPage < RecipeViewPage
  #   child_item_page_for Container, Recipe, :recipes
  # end

  class ContainerRecipeChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Container, Recipe, :recipes
  end
end