module ScrollingListHelper
  def scrolling_list_next_link(link_item, selected_item)
    per_default    = eval ("#{selected_item.class.name}.default_per_page")
    items_per_page = per_default

    if (@_controller.params[:per_page] != nil)
      items_per_page = @_controller.params[:per_page].to_i()
    end

    if @measuring_units.length >= items_per_page
      link_value = link_to_next_page(link_item, 'Next Page')
      if (link_value)
        link_value   = link_value.gsub(/\/new\/?/, "")
        link_value   = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
        append_value = ""
        unless (selected_item == nil || selected_item.id == nil)
          append_value = "?id=#{selected_item.id}"
        end
        unless (items_per_page == per_default)
          if (append_value.blank?)
            append_value = "?"
          else
            append_value += "&"
          end
          append_value += "per_page=#{items_per_page}"
        end
        unless (append_value.blank?)
          link_value = link_value.gsub(/href="(.*?)"/, "href=\"\\1#{append_value}\"")
        end

        return link_value.html_safe
      end
    end

    return nil
  end

  def scrolling_list_link_to_item(description, link_item, selected_item)
    item_class = ""
    unless (selected_item == nil)
      if (link_item.id === selected_item.id)
        item_class = " class=\"active\""
      end
    end
    "<li#{item_class}>#{link_to(description, link_item, class: "scroll-item-link")}</li>".html_safe
  end
end