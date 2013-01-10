module ScrollingListHelper
  def scrolling_list_next_link(link_item)
    link_value = link_to_next_page(link_item, 'Next Page')
    link_value = link_value.gsub(/(\/\d+\/?)?\?page=/, "/page/")
    link_value.html_safe
  end
end