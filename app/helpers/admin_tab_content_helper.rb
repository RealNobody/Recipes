module AdminTabContentHelper
  def tab_content parent_object, child_relationship, options = {}
    return_string = "".html_safe

    return_string << "<div class=\"recipe-tab-content\">\n".html_safe

    model_class = options[:model_class] || child_relationship.to_s.classify.constantize

    if parent_object.send(child_relationship).first
      return_string << render(partial: "full_page",
                              layout:  "scrollable_list/scrolling_list",
                              locals:
                                       {
                                           scroll_list_class:        "scrolling-list-related",
                                           model_class:              model_class,
                                           list_item:                parent_object.send(child_relationship).first,
                                           list_page:                parent_object.send(child_relationship).index_sort.page(1),
                                           list_params:              { page: 1 },
                                           show_path:                "#{model_class.name.tableize}/tab_show",
                                           list_content_name:        "#{child_relationship.to_s.singularize}_scroll_list".to_sym,
                                           item_content_name:        "#{child_relationship.to_s.singularize}_item".to_sym,
                                           list_parent_object:       parent_object,
                                           list_parent_relationship: child_relationship
                                       })
    else
      return_string << "No #{model_class.name.tableize.humanize}<br/>\n".html_safe
    end

    return_string << "</div>\n".html_safe
  end
end