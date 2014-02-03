root = exports ? this

# The content scrolling list is a scrolling list that when an item
# is clicked will update the content of another object on the screen with
# the results of the link in the item which was clicked.
#
# A scrolling list becomes a content scrolling list by adding a reference
# to the ID of the object which is to be updated with the result of the link
# in the scrolling-list attribute: "data-content-id".
#
# The items in the list contain links to the full page link for the item.
# This link will include the full page including the layout with menus
# and the scrolling list and everything.
#
# I don't use PJAX.  I made my own.
#
# To get only the contents of the area we want to replace, we have to change
# the URI to get the sub-piece we need.  The URI change is to append /item to the path.
#
# The URL for a full specific item is:
#   controller_path/<numeric id>
# The URL for a new item is:
#   controller_path/new
# The URL for the content are of a specific item is:
#   controller_path/item/<numeric id>
# The URL for the content are of a new item is:
#   controller_path/item/new
#
# The following parameters are expected to be supported:
#   * id=<id>
#     <id> will be the id of the selected item in the list
#     This ID may be an item that was already loaded, or an
#     item which may be scrolled into view.
#
#
# A content scrolling list needs 2 additional items on the page:
#
# 1) A link for a new item:
#     <div class="scrolling-list-new-link">
#       <a href="<link to new item>">
#
#   The "scrolling-list" and the "scrolling-list-new-link" objects must both be contained
#   within a single object with the class "scrolling-list-container"
#     <div class="scrolling-list-container">
#       <div class="well">
#         <div class="scrolling-list">
#       <div class="scrolling-list-new-link">
#
# 2) An item with an ID which matches the value in "data-content-id"
#     <div id="">
#
#   This item can be anywhere on the page, but it must be on the same page/window
#   as the scrolling list.

#$(".scrolling-list[data-content-id]")

root.ScrollingListContent = class ScrollingListContent
  constructor:             () ->
    @scrollingList = root.scrollingList

  # A function to return the object that is updated when an item is clicked.
  content_object:          (scrolling_list) ->
    content_id = scrolling_list.attr("data-content-id")
    $("#" + content_id)

  # Convert a URL to the URL for just the piece that we want.
  build_click_link:        (clicked_href) ->
    clicked_href.replace(/((?:.*?\/)+)/, "$1item/")

  # Convert a URL for a specific item to the URL for a new item
  build_new_link:          (clicked_href) ->
    clicked_href.replace(/((?:.*?\/)+)\d+/, "$1new")

  # Extract the ID portion of a URL to a specific item.
  get_item_link_id:        (link_url) ->
    get_id = link_url.match(/\/(\d+)(?:\?.*)?$/)

    if (get_id)
      return get_id[1]

    get_id = link_url.match(/\/(new$)/)
    if (get_id)
      return get_id[1]

    null

  # The callback funciton when a list item in a content list is clicked.
  click_item:              (eventData) ->
    scroll_class = eventData.data.scroll_class
    clicked_item = $(eventData.currentTarget)
    scrolling_list = clicked_item.closest(".scrolling-list")

    scroll_class.show_item(eventData, scrolling_list, clicked_item.attr("href"))

  # The callback function when the new link is clicked.
  click_new_item:          (eventData) ->
    scroll_class = eventData.data.scroll_class
    clicked_item = $(eventData.currentTarget)
    scrolling_list = clicked_item.closest(".scrolling-list-container")

    scrolling_list = scrolling_list.find(".scrolling-list")
    clicked_item = clicked_item.find("a")
    scroll_class.show_item(eventData, scrolling_list, clicked_item.attr("href"))

  # This puts the actual content into the content object.
  display_content_on_page: (scrolling_list, display_content, item_url, clicked_item_url, item_id, requestFailed) ->
    scroll_content = this.content_object(scrolling_list)

    #Set the HTML of the item display.
    scroll_content.html(display_content)

    #switch the active item in the list.
    scrolling_list.find(".active").removeClass("active")
    search_url = @scrollingList.build_find_link(clicked_item_url)
    new_active_item = scrolling_list.find("a[href=\"" + search_url + "\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href^=\"" + search_url + "?\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href*=\"" + search_url + "?\"]")
    if (new_active_item.length > 0)
      new_active_item.closest("li").addClass("active")

    # If there is a "next" link in the scrolling list, update it
    # to set the value of the selected item, so if we refresh the page,
    # or if we scroll and the item isn't currently visible, it will be
    # selected appropriately.
    this.set_next_link(scrolling_list, "scrolling-next", item_id)
    this.set_next_link(scrolling_list, "scrolling-previous", item_id)

    item_links = scrolling_list.find("li a")
    for item_link in item_links
      this.set_link_id($(item_link), item_id)

    # Fire an event to let others know that the content has been loaded.
    scroll_content.trigger("scroll_content_loaded", [ scrolling_list.attr("id"), display_content, item_url, clicked_item_url, item_id, requestFailed ])

    # This shouldn't be necessary, but I cannot get .on("scroll", ".scrolling-list"...) to
    # bind to the scrolling list controller.  I have to explicitly call
    # $(".scrolling-list").bind("scroll"...)
    # Since the loaded page could have scrolling lists, so we need to rebind elements
    @scrollingList.bind_elements()

  # This function fires the AJAX call to get the data, then puts it into the right location.
  show_item:               (eventData, scrolling_list, clicked_item_url) ->
    item_url = this.build_click_link(clicked_item_url)
    item_id = this.get_item_link_id(item_url)
    clicked_item_url = clicked_item_url.replace(/([\?&])id=(:?\d+|new)/, "$1id=" + item_id)

    eventData.preventDefault()

    if (item_id)
      $.ajax(
        url:      item_url,
        dataType: "html"
      ).done((display_content) =>
        this.display_content_on_page(scrolling_list, display_content, item_url, clicked_item_url, item_id, false)
      ).fail((xHeader, status_info, error_Thrown) =>
        # if the request fails with a 404, then it will return an empty record.
        if (xHeader.status == 404)
          new_url = scroll_class.build_new_link(clicked_item_url)
          item_url = scroll_class.build_click_link(new_url)
          item_id = "new"
          this.display_content_on_page(scrolling_list, xHeader.responseText, item_url, new_url, item_id, true)
        # else
        # Erik do something about the error
      )

  # This is a helper funciton to update the value in the next or previous
  # link to set the selected item to the currently selected item.
  set_next_link:           (scrolling_list, next_link_class, item_id) ->
    next_link = scrolling_list.find(".#{next_link_class} a")

    if (next_link.length > 0)
      this.set_link_id(next_link, item_id)

  # Given an object, set the id for the href on the object
  set_link_id: (link_object, item_id) ->
    link_url = link_object.attr("href")
    link_url = link_url.replace(/([\?&])id=(:?\d+|new)/, "$1id=" + item_id)
    link_object.attr("href", link_url)

  # This function gets the title for the information for the item.
  # The title comes from a hidden item on the form which contains
  # the title for the shown page.
  get_title:               (item_url) ->
    title_text = null
    object_type = item_url.match(/\/?([^\/]+)/)[1]
    title_object = $("#" + object_type + "-title")
    if (title_object.length > 0)
      title_text = title_object.attr("value")

  document_ready: ->
    $(document).on("click", ".scrolling-list .scroll-item-link", { scroll_class: this }, this.click_item)
    $(document).on("click", ".scrolling-list-new-link", { scroll_class: this }, this.click_new_item)

root.contentScrollList = null

$(document).ready(->
  if (!root.contentScrollList)
    root.contentScrollList = new root.ScrollingListContent()

  root.contentScrollList.document_ready()
)