module ScrollingListHelper
  def scrolling_list_next_link(page_items, current_item, param_page, param_per_page, per_page_model)
    per_default    = per_page_model
    items_per_page = per_default

    if (param_per_page != nil)
      items_per_page = param_per_page.to_i()
    end

    if page_items.length >= items_per_page
      if page_items == @current_page
        link_value = link_to_next_page(page_items, I18n.t("scrolling_list.picker.next_page"))
      else
        unless (page_items.last_page?)
          link_value = "#{eval("#{page_items.klass.name.pluralize.underscore}_url")}/page/#{page_items.current_page + 1}"
          link_value = link_to("Next Page", link_value)
        end
      end
      if (link_value)
        link_value   = link_value.gsub(/\/new\/?/, "")
        link_value   = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
        append_value = ""
        if (current_item == nil || current_item.id == nil)
          append_value = "?id=new"
        else
          append_value = "?id=#{current_item.id}"
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

  def scrolling_list_previous_link(page_items, current_item, param_page, param_per_page, per_page_model)
    per_default    = per_page_model
    items_per_page = per_default

    if (param_per_page != nil)
      items_per_page = param_per_page.to_i()
    end

    if page_items && page_items.current_page > 1
      if page_items == @current_page
        link_value = link_to_previous_page(page_items, I18n.t("scrolling_list.picker.previous_page"))
      else
        unless (page_items.first_page?)
          link_value = "#{eval("#{page_items.klass.name.pluralize.underscore}_url")}/page/#{page_items.current_page - 1}"
          link_value += "?id=" + current_item.id.to_s() if current_item
          link_value = link_to("Previous Page", link_value)
        end
      end
      if (link_value)
        link_value   = link_value.gsub(/\/new\/?/, "")
        link_value   = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
        append_value = ""
        if (current_item == nil || current_item.id == nil)
          append_value = "?id=new"
        else
          append_value = "?id=#{current_item.id}"
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

  def scroll_list_name(current_item)
    ScrollingListHelper.scroll_list_name(current_item)
  end

  def self.scroll_list_name(current_item)
    if (current_item.respond_to?("list_name"))
      current_item.list_name
    else
      if (current_item.respond_to?("name"))
        current_item.name
      else
        current_item.to_s()
      end
    end
  end

  def scrolling_list_link_to_item(description, link_item, page_items, current_item, param_page, param_per_page, per_page_model)
    item_class = ""
    unless (current_item == nil)
      if (link_item.id === current_item.id)
        item_class = " class=\"active\""
      end
    end

    link_item = url_for(link_item)
    if link_item =~ /\?/
      link_connector = "&"
    else
      link_connector = "?"
    end

    if (param_page)
      link_item += "#{link_connector}page=#{param_page}"
    end
    if (param_per_page)
      link_item += "#{link_connector}per_page=#{param_per_page}"
    end

    "<li#{item_class}>#{link_to(description, link_item, class: "scroll-item-link")}</li>".html_safe
  end

  #def scrolling_list_page_break(prev_link, next_link, page_items, current_item, param_page, param_per_page, per_page_model)
  #  per_page = nil
  #  page_num = 1
  #  if (param_page)
  #    page_num = param_page
  #  end
  #  if (param_per_page)
  #    per_page = " data-per_page=\"#{param_per_page}\""
  #  end
  #
  #  "<li class=\"scroll-page-break\" data-page=\"#{page_num}\"#{per_page} data-prev_link=\"#{prev_link}\" data-next_link=\"#{next_link}\" />".html_safe
  #end
end