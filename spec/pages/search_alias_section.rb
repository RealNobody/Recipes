require "pages/pick_dialog_section"
require "pages/item_edit_section"

class SearchAliasSection < ItemEditSection
  element :container, "#link_search_alias_aliased_id"
  element :pick_search, "#pick_search_alias_aliased_id"
  section :pick_dialog_search, PickDialogSection, "#search_alias .scrolling-picker-dialog"

  element :alias_field, "#search_alias_alias"

  def populate_hash_values(values)
    pick_item(self, values, :search_alias, values[:aliased_type].underscore)

    alias_field.set(values[:alias])
  end
end