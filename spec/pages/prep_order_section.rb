require "pages/item_edit_section"

class PrepOrderSection < ItemEditSection
  element :name, "#prep_order_name"
  element :order, "#prep_order_order"

  def populate_hash_values(values)
    name.set(values[:name])
    order.set(values[:order])
  end
end