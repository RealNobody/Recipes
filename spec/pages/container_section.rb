require "pages/item_edit_section"

class ContainerSection < ItemEditSection
  element :name, "#container_name"

  def populate_hash_values(values)
    name.set(values[:name])
  end
end