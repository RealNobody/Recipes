def test_scroll_list_name(class_item)
  if class_item.respond_to?(:list_name)
    class_item.send(:list_name)
  else
    if class_item.respond_to?(:name)
      class_item.send(:name)
    else
      class_item.to_s
    end
  end
end

def pick_item(page_object, values, base_class, pick_class, field_alias = nil)
  field_alias ||= pick_class
  unless page_object.send(field_alias)[:href] == "#{pick_class.pluralize}/#{values["#{field_alias}_id".to_sym]}"
    find_object = pick_class.constantize.find(id: values["#{field_alias}_id".to_sym])
    if all("#pick_#{base_class}_#{field_alias}_id").length > 0
      page_object.send("pick_#{field_alias}").click

      dialog_obj = page_object.send("pick_dialog_#{pick_class}")
      init_field = pick_class.constantize.initialize_field
      dialog_obj.search.set(find_object[init_field])
      max_loops = 10 * 10
      while max_loops > 0 && dialog_obj.results.items[0].text != test_scroll_list_name(find_object[init_field])
        sleep(0.1)
        max_loops -= 1
      end

      dialog_obj.results.items[0].click
    end
  end
end