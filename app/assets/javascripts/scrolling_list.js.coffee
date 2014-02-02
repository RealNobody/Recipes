root = exports ? this

# A scrolling list is a list which scrolls.  The idea being that we don't want to
# have to bring the entire list down from the server, and we will load it as it scrolls
# and the user wants to see the data.
#
# This is mostly done as an exercise because I'm learning, but it could have useful applications.
#
# For now, the page sizes of data are small.
#
# The scrolling list content is brought down as HTML, so it is formatted on the server.
#
# There are a lot of rules for the scroll list.
#
# The list is based off of bootstrap, and is setup as follows:
# <div class="well">
#   <div class="scrolling-list">
#     <ul class="scrolling-list-content nav nav-list">
#
# "scrolling-list" is the class used to specify the container that contains all of the scrolling list
# items.  This is the primary container that is considered the scrolling list.
#
# "scrolling-list-content" is the class used to specify the UL item that contains the list items.
#
# The list contents will roughly be formatted as:
#   <div class="scrolling-previous">
#     <a href="link to previous page of data"></a>
#   </div>
#   <li class="active">
#     <a href="link to item">display item</a>
#   </li>
#   <div class="scrolling-next">
#     <a href="link to next page of data"></a>
#   </div>
#
# Each page that is downloaded will be formatted with the same elements as in the list.
# When the page is sent, we will insert it into the list at the top or bottom as appropriate and
# remove the "touching" page divs.
#   For example, if inserting at the bottom of the list, we will remove the old next div, and the
#   new previous div.
#
# If there is no next or previous div, there is no more data.
#
# The scrolling list class is responsible for asking the question "is the wait icon for the
# next/previous page of data showing?"
#
# If the answer is yes, then that page of data is requested, and when it is returned, it is placed
# in the list at the correct location.
#
# This class only listens for the scroll event.
#
# If a page of data is loaded, then this class will fire a "scroll_load_finished" event on the list scroll div

root.ScrollingList = class ScrollingList
  # When the document is ready, bind all scrolling lists to the appropriate functions that this
  # class takes care of, and if necessary, tell the system to load more items.
  document_ready:  () ->
    this.bind_elements()

    scrolling_lists = $(".scrolling-list")

    # for each scroll list on the page...
    for scrolling_list in scrolling_lists
      scrolling_list = $(scrolling_list)
      # if the scroll_next item is in the list, and the top is visible, then scroll the list...
      scroll_next = scrolling_list.find(".scrolling-next")
      scroll_next_height = 0
      if (scroll_next.length > 0)
        scroll_next_height = scroll_next.height()

      # if the next item is viaible, fire a scroll event...
      if (scrolling_list.get(0).scrollHeight > scroll_next_height && (scrolling_list.get(0).scrollHeight - scroll_next_height) <= scrolling_list.innerHeight())
        this.fire_scroll(scrolling_list)

    true

  # determine if more data needs to be fetched, and return a hash with information about the decision...
  # Parameters:
  #   scroll_list:  The list object which we want to know if it needs to be scrolled or not.
  #
  # Return value:
  #   {
  #     scroll_down:          True if the link is for more data at then end of the scroll
  #     scroll_up:            True if the link is for more data at the start of the scroll
  #     scroll_down_visible:  True if the scroll down wait symbol can be seen
  #     scroll_up_visible:    True if the scroll up wait symbol can be seen
  #     scroll_up_height:     The height of the scroll up wait symbol
  #     scroll_link:          The link element with the link to the scroll data to fetch
  #   }
  should_scroll:   (scroll_list) ->
    scroll_info =
      scroll_down:         false,
      scroll_up:           false,
      scroll_down_visible: false,
      scroll_up_visible:   false,
      scroll_up_height:    0,
      scroll_link:         null

    scroll_next = scroll_list.find(".scrolling-next")
    scroll_next_height = 0
    if (scroll_next.length > 0)
      scroll_info.scroll_link = $(scroll_next.find("a"))
      scroll_next_height = scroll_next.height()

      scroll_info.scroll_down_visible = scroll_list.find(".scrolling-list-content").height() - scroll_list.scrollTop() - scroll_list.innerHeight() - scroll_next_height < 0
      # There is a next link
      if ((scroll_list.get(0).scrollHeight - scroll_next_height) <= scroll_list.innerHeight() || scroll_info.scroll_down_visible)
        # The wait can be seen because
        # (There is less information than the scroll contents) || (The wait icon can be seen)
        scroll_info.scroll_down = true
    else
      scroll_next_height = $(scroll_list.find("ul li:last-child")).height()
      scroll_info.scroll_down_visible = scroll_list.find(".scrolling-list-content").height() - scroll_list.scrollTop() - scroll_list.innerHeight() - scroll_next_height < 0
      scroll_next_height = 0

    unless (scroll_info.scroll_down)
      scroll_next = scroll_list.find(".scrolling-previous")

      if (scroll_next.length > 0)
        scroll_info.scroll_link = $(scroll_next.find("a"))
        scroll_next_height = scroll_next.height()

        scroll_info.scroll_up_height = scroll_next_height
        scroll_info.scroll_up_visible = scroll_list.scrollTop() < scroll_next_height

        if (scroll_list.get(0).scrollHeight - scroll_next_height <= scroll_list.innerHeight() || scroll_info.scroll_up_visible)
          scroll_info.scroll_up = true
      else
        scroll_next_height = 0

    scroll_info

  # Helper function used to add the add_content values to the scroll_list
  # It will pre-pend or append the data based on the scroll_info.
  append_content:  (scroll_list, scroll_info, add_content) ->
    scroll_down_class = ".scrolling-next"
    scroll_up_class = ".scrolling-previous"

    if (scroll_info.scroll_up)
      scroll_up_class = ".scrolling-next"
      scroll_down_class = ".scrolling-previous"

    scroll_list.find(scroll_down_class).remove()
    add_content.find(scroll_up_class).remove()

    if (scroll_info.scroll_up)
      scroll_cur = $(scroll_list.find("ul li:first-child"))
      scroll_offset = 0

      scroll_list.find("ul").prepend(add_content.html())

      # Scroll up the height of each of the just pre-pended items...
      scroll_cur = scroll_cur.prev()
      while (scroll_cur.length > 0)
        scroll_offset += scroll_cur.height()
        scroll_cur = scroll_cur.prev()

      scroll_list.scrollTop(scroll_list.scrollTop() + scroll_offset)
    else
      scroll_list.find("ul").append(add_content.html())

  # The list is scrolling.  Fetch the next page of data...
  # Parameters:
  #   scroll_list: The list which is scrolling...
  list_scrolling:  (scroll_list) ->
    if (!scroll_list.hasClass("scrolling-fetching"))
      scroll_list.addClass("scrolling-fetching")

      scroll_info = this.should_scroll(scroll_list)

      if (scroll_info.scroll_up || scroll_info.scroll_down)
        $.ajax(
          url:      scroll_info.scroll_link.attr("href"),
          dataType: "html"
        ).done((additional_content) =>
          add_content = $('<div/>').html(additional_content)
          search_links = add_content.find("li a")
          found_link = null

          # I don't know why, but when going forward and back, the system caches
          # some of the links, so I have to check if they are already there...
          # NOTE: This probably doesn't work as intended any more...
          if (search_links.length > 0)
            for search_link in search_links
              search_link_href = $(search_link).attr("href")
              search_url = this.build_find_link(search_link_href)
              found_link = scroll_list.find("a[href=\"" + search_url + "\"]")
              if (found_link.length <= 0)
                found_link = scroll_list.find("a[href^=\"" + search_url + "?\"]")
              if (found_link.length <= 0)
                found_link = scroll_list.find("a[href*=\"" + search_url + "?\"]")

          # We didn't have any items in the list, or we didn't find any of the items returned
          # so we add the returned data to the page.
          if (found_link? && found_link.length > 0)
            # The returned data includes one or more fields already on the page
            # so we replace all data with the returned page, and load it up...
            scroll_list.find("ul").html(add_content.html())
          else
            # Remove the old next that was used to get the new page.
            # if there is a new next, it will be in the content that we are
            # appending.
            this.append_content(scroll_list, scroll_info, add_content)

          # alert others that we've changed the list.
          scroll_list.trigger("scroll_items_changed")

          new_scroll_info = this.should_scroll(scroll_list)

          # find out if we can scroll the page up a little to hide the scroll up wait icon.
          if (new_scroll_info.scroll_up_visible && !new_scroll_info.scroll_down_visible)
            # scroll the window up to hide the scroll-up if necessary/possible.
            scroll_amount = scroll_list.get(0).scrollHeight - scroll_list.innerHeight()
            if (scroll_amount > new_scroll_info.scroll_up_height)
              scroll_amount = new_scroll_info.scroll_up_height

            scroll_list.scrollTop(scroll_amount)

            new_scroll_info = this.should_scroll(scroll_list)

          # If after scrolling the scroll-up out of view if possible, if one of the scrolls is still showing, scroll again.
          if (new_scroll_info.scroll_down || new_scroll_info.scroll_up)
            # Only fire the scroll action if there is more data to fetch.
            if (new_scroll_info.scroll_link && new_scroll_info.scroll_link.length > 0)
              this.fire_scroll(scroll_list)
        ).fail(=>
          # do something here about the failure...
        ).always(=>
          scroll_list.removeClass("scrolling-fetching")
          scroll_list.trigger("scroll_load_finished")
        )
      else
        scroll_list.removeClass("scrolling-fetching")

  # A helper function to be used multiple places.
  # Given a full URL link, what is the call for a new item.
  build_find_link: (clicked_href) ->
    query_pos = clicked_href.indexOf("?")

    if (query_pos >= 0)
      clicked_href = clicked_href.substr(0, query_pos)
    if (clicked_href.substr(clicked_href.length - 1) == "/")
      clicked_href = clicked_href.substr(0, clicked_href.length - 1)
    if (clicked_href.substr(clicked_href.length - 5) == "/edit")
      clicked_href = clicked_href.substr(0, clicked_href.length - 5)

    clicked_href

  # "scroll" the page by fetching more data...
  scroll_event:    (eventData) ->
    scroll_class = eventData.data.scroll_class
    scroll_class.list_scrolling($(eventData.target))

  # This function is used to bind the elements on the screen that this class
  # effects to the functions that respond to those objects.
  bind_elements:   () ->
    $(".scrolling-list").unbind("scroll", this.scroll_event)
    $(".scrolling-list").bind("scroll", { scroll_class: this }, this.scroll_event)

  # This function fires the scroll event for the list, causing it to load more fields
  fire_scroll:     (scrolling_list) ->
    window.setTimeout(->
      scrolling_list.trigger("scroll")
    , 5)

  reset_scroll: (scroll_list, new_url) ->
    if (!scroll_list.hasClass("scrolling-fetching"))
      scroll_list.addClass("scrolling-fetching")

      $.ajax(
        url:      new_url,
        dataType: "html"
      ).done((new_content) =>
        $(scroll_list.find("ul")).html(new_content)
        this.fire_scroll(scroll_list)
      ).fail(=>
        # Erik do something about the error
      ).always(=>
        scroll_list.removeClass("scrolling-fetching")
        scroll_list.trigger("scroll_load_finished")
      )

#  scrub_unseen_pages: function (scroll_div)
#  {
#    var cache_pages = scroll_div.attr ("data-cache-pages");
#
#    // $($(".scroll-page-break")[2]).offset().top + $($(".scroll-page-break")[2]).height() - $(".scrolling-list").offset().top
#    if (!cache_pages)
#      cache_pages = 0;
#    else
#      cache_pages = parseInt (cache_pages);
#
#    var page_markers = scroll_div.find (".scroll-page-break");
#
#    if (page_markers.length > cache_pages)
#    {
#      var top_page_index = cache_pages;
#      var div_offset = scroll_div.offset ().top;
#      var delete_item;
#      var page_item;
#      var delete_height;
#
#      while ($ (page_markers [top_page_index]).offset ().top + $ (page_markers [top_page_index]).height () - div_offset <= 0)
#      {
#        top_page_index += 1;
#      }
#      top_page_index -= 1;
#
#      if (top_page_index >= cache_pages)
#      {
#        page_item = $ (page_markers [top_page_index]).attr ("data-page");
#        delete_item = $ (scroll_div.find ("li:first"));
#        while (delete_item.attr ("data-page") != page_item)
#        {
#          delete_height = delete_item.height ();
#          delete_item.remove ();
#          scroll_div.scrollTop (scroll_div.scrollTop () - delete_height);
#          delete_item = $ (scroll_div.find ("li:first"));
#        }
#        delete_height = delete_item.height ();
#        var prev_link = delete_item.attr ("data-prev_link");
#        delete_item.remove ();
#        scroll_div.scrollTop (scroll_div.scrollTop () - delete_height);
#        prev_link = $ ("<div class=\"scrolling-previous\"><a href=\"" + prev_link + "\">prev</a></div>");
#        delete_height = prev_link.height ();
#        $ (scroll_div.find (ul))
#      }
#    }
#  },

root.scrollingList = null

$(document).ready( ->
  if (!root.scrollingList)
    root.scrollingList = new root.ScrollingList()

  root.scrollingList.document_ready()
)