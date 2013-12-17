class ScrollingListPagePage < RecipePage
  set_url "/measuring_units/page/{page_number}{?query*}"
  set_url_matcher /\/measuring_units\/page\/(:?\/\d+)?/

  element :selected_item, ".active"
  element :wait_next, ".scrolling-next"
  element :wait_previous, ".scrolling-previous"
  elements :list_items, "li a"
end