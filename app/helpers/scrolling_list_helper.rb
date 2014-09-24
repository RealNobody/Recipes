module ScrollingListHelper
  def scrolling_list_next_link(page_items,
      current_item,
      param_page,
      param_per_page,
      per_page_model,
      search_text,
      parent_object,
      parent_relationship)
    per_default    = per_page_model
    items_per_page = per_default

    if (param_per_page != nil)
      items_per_page = param_per_page.to_i()
    end

    if page_items.length >= items_per_page
      route_params = {}
      if (parent_object)
        route_params[:params] = { use_route: "#{parent_object.class.name.underscore}_#{parent_relationship}" }
      end
      if page_items == @current_page
        link_value = link_to_next_page(page_items, I18n.t("scrolling_list.picker.next_page"), route_params)
      else
        unless (page_items.last_page?)
          if (parent_object)
            link_value = "#{self.send("#{parent_object.class.name.underscore}_#{parent_relationship}_url", parent_object)}/page/#{page_items.current_page + 1}"
          else
            link_value = "#{self.send("#{page_items.klass.name.tableize}_url")}/page/#{page_items.current_page+ 1}"
          end
          link_value = link_to("Next Page", link_value, route_params)
        end
      end
      if (link_value)
        link_value = link_value.gsub(/\/new\/?/, "")
        link_value = link_value.gsub(/(\/\d+(\/edit)?\/?)?\?page=/, "/page/")

        if (current_item && current_item.id && !current_item.new_record?)
          append_value = "?id=#{current_item.id}"
        else
          append_value = "?id=new"
        end
        unless (items_per_page == per_default)
          append_value += "&per_page=#{items_per_page}"
        end
        if (search_text)
          append_value += "&search=#{ERB::Util.url_encode(search_text)}"
        end
        unless (append_value.blank?)
          link_value = link_value.gsub(/href="(.*?)"/, "href=\"\\1#{append_value}\"")
        end

        return link_value.html_safe
      end
    end

    return nil
  end

  def scrolling_list_previous_link(page_items,
      current_item,
      param_page,
      param_per_page,
      per_page_model,
      search_text,
      parent_object,
      parent_relationship)
    per_default    = per_page_model
    items_per_page = per_default

    if (param_per_page != nil)
      items_per_page = param_per_page.to_i()
    end

    if page_items && page_items.current_page > 1
      route_params = {}
      if (parent_object)
        route_params[:params] = { use_route: "#{parent_object.class.name.underscore}_#{parent_relationship}" }
      end
      if page_items == @current_page
        link_value = link_to_previous_page(page_items, I18n.t("scrolling_list.picker.previous_page"), route_params)
      else
        unless (page_items.first_page?)
          if (parent_object)
            link_value = "#{self.send("#{parent_object.class.name.underscore}_#{parent_relationship}_url", parent_object)}/page/#{page_items.current_page - 1}"
          else
            link_value = "#{self.send("#{page_items.klass.name.tableize}_url")}/page/#{page_items.current_page - 1}"
          end
          link_value = link_to("Previous Page", link_value, route_params)
        end
      end

      if (link_value)
        link_value = link_value.gsub(/\/new\/?/, "")
        link_value = link_value.gsub(/(\/\d+(\/edit)?\/?)?\?page=/, "/page/")

        if (current_item && current_item.id && !current_item.new_record?)
          append_value = "?id=#{current_item.id}"
        else
          append_value = "?id=new"
        end
        unless (items_per_page == per_default)
          append_value += "&per_page=#{items_per_page}"
        end
        if (search_text)
          append_value += "&search=#{ERB::Util.url_encode(search_text)}"
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
    elsif (current_item.respond_to?("name"))
      current_item.name
    else
      current_item.to_s()
    end
  end

  def scrolling_list_link_to_item(description,
      link_item,
      page_items,
      current_item,
      param_page,
      param_per_page,
      per_page_model,
      search_text,
      parent_object,
      parent_relationship)
    item_class = ""

    link_item_id = link_item.id

    if (parent_object)
      link_item = send("#{parent_object.class.name.underscore}_#{parent_relationship.to_s.singularize}_path",
                       parent_object,
                       link_item)
    else
      link_item = url_for(link_item)
    end

    #if link_item =~ /\?/
    #  link_connector = "&"
    #else
    link_connector = "?"
    #end

    if (param_page)
      link_item      += "#{link_connector}page=#{param_page}"
      link_connector = "&"
    end
    if (param_per_page && param_per_page != per_page_model)
      link_item      += "#{link_connector}per_page=#{param_per_page}"
      link_connector = "&"
    end
    if (search_text)
      link_item      += "#{link_connector}search=#{ERB::Util.url_encode(search_text)}"
      link_connector = "&"
    end
    if (current_item)
      if (link_item_id === current_item.id)
        item_class = " class=\"active\""
      end

      if (current_item && current_item.id && !current_item.new_record?)
        link_item += "#{link_connector}id=#{current_item.id}"
      else
        link_item += "#{link_connector}id=new"
      end
    end

    route_params = { class: "scroll-item-link" }
    if (parent_object)
      route_params[:params] = { use_route: "#{parent_object.class.name.underscore}_#{parent_relationship}" }
    end
    Rails.logger.error("returned item = <li#{item_class}>#{link_to(description, link_item.html_safe, route_params)}</li>".html_safe)
    "<li#{item_class}>#{link_to(description, link_item.html_safe, route_params)}</li>".html_safe
  end

  def page_title_field
    hidden_field_tag("#{@model_class.name.tableize}-title", page_title)
  end

  def page_title
    if @model_class
      i18n_name     = "admin.#{@model_class.name.to_s.singularize.underscore}.title"
      default_title = I18n.t("admin.default.title_format")
      title         = I18n.t(i18n_name, default: default_title)
      title % { unit_type: @model_class.model_name.human.titleize,
                unit_name: scroll_list_name(@selected_item) }
    else
      I18n.t("admin.default.title")
    end
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