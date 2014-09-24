require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"

module RecipePages
  class KeywordSection < ItemEditSection
    element :name, "#keyword_name"
  end

  class KeywordEditPage < RecipeAppPage
    def populate_hash_values(values)
      keyword_tab.click if has_keyword_tab?

      keyword.name.set(values[:name])
    end

    def validate_hash_values(values)
      expect(keyword.name.value).to eq(values[:name])
    end
  end

  class KeywordFullPage < KeywordEditPage
    full_page_for Keyword
  end

  class KeywordItemPage < KeywordEditPage
    item_page_for Keyword
  end

  class KeywordScrollingListPage < RecipeAppPage
    scrolling_list_page_for Keyword
  end

  class KeywordSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for Keyword, SearchAlias, :search_aliases
  end

  class KeywordSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Keyword, SearchAlias, :search_aliases
  end
end