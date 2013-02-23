module ScrollingListHelper
  def scrolling_list_next_link()
    per_default    = @model_per_page
    items_per_page = per_default

    if (@_controller.params[:per_page] != nil)
      items_per_page = @_controller.params[:per_page].to_i()
    end

    if @current_page.length >= items_per_page
      link_value = link_to_next_page(@current_page, 'Next Page')
      if (link_value)
        link_value   = link_value.gsub(/\/new\/?/, "")
        link_value   = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
        append_value = ""
        if (@selected_item == nil || @selected_item.id == nil)
          append_value = "?id=new"
        else
          append_value = "?id=#{@selected_item.id}"
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

  def scrolling_list_previous_link()
    per_default    = @model_per_page
    items_per_page = per_default

    if (@_controller.params[:per_page] != nil)
      items_per_page = @_controller.params[:per_page].to_i()
    end

    if @_controller.params[:page] && @_controller.params[:page].to_i() > 1
      link_value = link_to_previous_page(@current_page, 'Previous Page')
      if (link_value)
        link_value   = link_value.gsub(/\/new\/?/, "")
        link_value   = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
        append_value = ""
        if (@selected_item == nil || @selected_item.id == nil)
          append_value = "?id=new"
        else
          append_value = "?id=#{@selected_item.id}"
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

  def scrolling_list_link_to_item(description, link_item)
    item_class = ""
    unless (@selected_item == nil)
      if (link_item.id === @selected_item.id)
        item_class = " class=\"active\""
      end
    end

    link_item = url_for(link_item)
    if link_item =~ /\?/
      link_connector = "&"
    else
      link_connector = "?"
    end

    if (@_controller.params[:page])
      link_item += "#{link_connector}page=#{@_controller.params[:page]}"
    end
    if (@_controller.params[:per_page])
      link_item += "#{link_connector}per_page=#{@_controller.params[:per_page]}"
    end

    "<li#{item_class}>#{link_to(description, link_item, class: "scroll-item-link")}</li>".html_safe
  end

  def scrolling_list_page_break prev_link, next_link
    per_page = nil
    page_num = 1
    if (@_controller.params[:page])
      page_num = @_controller.params[:page]
    end
    if (@_controller.params[:per_page])
      per_page = " data-per_page=\"#{@_controller.params[:per_page]}\""
    end

    "<li class=\"scroll-page-break\" data-page=\"#{page_num}\"#{per_page} data-prev_link=\"#{prev_link}\" data-next_link=\"#{next_link}\" />".html_safe
  end
end