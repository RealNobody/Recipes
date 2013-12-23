require "pages/scrolling_list_section"

class PickDialogSection < SitePrism::Section
  element :search, ".pick-dialog-search-text"
  section :results, ScrollingListSection, ".scrolling-list-content"

  def scroll(direction, number_of_elements)
    # I think I'm going to need this, but I don't want to take the time right now to
    # write it.  This needs to programatically scroll the list view.
    #
    # It needs to be done via JavaScript.
    #
    # I think I'll put the scroll function into the scrolling list javascript, and just add the
    # call here.
    #
    # I need to figure out how to get the JS object ID here.
    # I think I need to make the scrolling list require an ID...
    raise Exception.new "not implemented yet"
  end
end