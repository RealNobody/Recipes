require "pages/item_edit_section"

class KeywordSection < ItemEditSection
  element :name, "#keyword_name"

  def populate_hash_values(values)
    name.set(values[:name])
  end
end