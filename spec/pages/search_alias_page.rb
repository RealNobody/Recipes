require "pages/pick_dialog_section"
require "pages/item_edit_section"
require "pages/recipe_app_page"

module RecipePages
  class SearchAliasShowSection < ItemEditSection
    element :aliased_item, "#link_search_alias_aliased_id"
    element :alias_field, "#search_alias_alias"
  end

  class SearchAliasSection < SearchAliasShowSection
    # element :aliased_item, "#link_search_alias_aliased_id"
    element :pick_search, "#pick_search_alias_aliased_id"
    section :pick_dialog_search, PickDialogSection, "#search_alias .scrolling-picker-dialog"

    # element :alias_field, "#search_alias_alias"
  end

  class SearchAliasEditPage < RecipeAppPage
    def populate_hash_values(values)
      search_alias_tab.click if has_search_alias_tab?

      pick_item(search_alias, values, :search_alias, values[:aliased_type].underscore)

      search_alias.alias_field.set(values[:alias])
    end

    def validate_hash_values(values)
      expect(search_alias.aliased_item[:href]).to eq("/#{values[:aliased_type].tableize}/#{values_aliased_id}")
      expect(search_alias.alias_field.value).to eq(values[:alias])
    end
  end

  class SearchAliasViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(aliased_item[:href]).to eq("/#{values[:aliased_type].tableize}/#{values_aliased_id}")
      expect(alias_field.text).to eq(values[:alias])
    end
  end

  class SearchAliasFullPage < SearchAliasEditPage
    full_page_for SearchAlias
  end

  class SearchAliasItemPage < SearchAliasEditPage
    item_page_for SearchAlias
  end

  class SearchAliasScrollingListPage < RecipeAppPage
    scrolling_list_page_for SearchAlias
  end
end