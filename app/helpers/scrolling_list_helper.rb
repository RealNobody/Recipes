module ScrollingListHelper
  def scrolling_list_next_link(link_item, selected_item)
    link_value = link_to_next_page(link_item, 'Next Page')
    link_value = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
    unless (selected_item == nil)
      link_value = link_value.gsub(/href="(.*?)"/, "href=\"\\1?id=#{selected_item.id}\"")
    end
    link_value.html_safe
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