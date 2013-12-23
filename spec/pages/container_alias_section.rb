require "pages/pick_dialog_section"
require "pages/item_edit_section"

class ContainerAliasSection < ItemEditSection
  element :container, "#link_container_alias_container_id"
  element :pick_container, "#pick_container_alias_container_id"
  section :pick_dialog_container, PickDialogSection, "#pick-scroll-container"

  element :alias_field, "#container_alias_alias"

  def populate_hash_values(values)
    pick_item(self, values, :container_alias, :container)

    alias_field.set(values[:alias])
  end
end