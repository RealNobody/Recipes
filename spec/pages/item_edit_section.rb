require "pages/layout_section"

class ItemEditSection < SitePrism::Section
  element :save, "input[name=commit]"
  element :delete, "#delete-admin-item"
end