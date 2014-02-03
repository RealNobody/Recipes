root = exports ? this

# The admin scroll class is responsible for doing the actions that are specific to the scrolling
# list that is used in the administrative pages.
#
# The administrative list is identified by the class "scrolling-list-primary".  This class must be
# set on the same object as the "scrolling-list" object.
#
# The height of the scrolling list is based off of the height of the object with the class
# "recipe-container", and the "debug_dump" object, and the "scrolling-list-new-link" object.

root.ScrollingListAdmin = class ScrollingListAdmin
  constructor:             () ->
    @minimum_max_height = 160
    @scrollingList = root.scrollingList
    @contentScrollingList = root.contentScrollList

  # Caclulate and return the minimum height of the administrative list
  calculate_min_height:    ->
    top_offset = 0
    min_height = 0
    debug_height = 0
    debug_padding = 10
    scroll_list_padding = 2

    if ($(window).width() < 767)
      return @minimum_max_height

    scrolling_list = $(".scrolling-list-primary")
    recipe_container = $(".recipe-container")

    offset_item = scrolling_list
    #while (offset_item && !offset_item.hasClass("recipe-container"))
    top_offset += offset_item.offset().top
    #  offset_item = $(offset_item.offsetParent())

    debug_area = $(".debug_dump")
    if (debug_area.length > 0)
      debug_height = debug_area.height() + debug_padding
    min_height = recipe_container.height() - top_offset + root.RecipeApp.container_margin - debug_height - scroll_list_padding
    if (min_height < @minimum_max_height)
      min_height = @minimum_max_height

    min_height

  # actually set the max-height value for the control.
  adjust_size:             ->
    max_height = this.calculate_min_height()
    min_height = max_height
    scrolling_list = $(".scrolling-list-primary")
    new_link = $(".scrolling-list-new-link")

    max_height -= root.RecipeApp.container_margin

    if (!scrolling_list.hasClass("scroll-list-do-not_adjust-height"))
      scrolling_list.css("max-height", (max_height - new_link.height() - root.RecipeApp.container_margin).toString() + "px")

    @contentScrollingList.content_object(scrolling_list).css("min-height", min_height.toString() + "px")

    @scrollingList.list_scrolling(scrolling_list)

  # When content is displayed on the page, we may have to update the history.
  display_content_on_page: (eventData, scrolling_list_id, display_content, item_url, clicked_item_url, item_id, requestFailed) =>
    #If the history option is supported, use it to update the title and the URL.
    if (@history_supported)
      scrolling_list = $("##{scrolling_list_id}")
      title_text = null

      history_info =
        scroll_id: scrolling_list.attr("id"),
        link_url:  clicked_item_url,
        ajax_url:  item_url

      title_text = @contentScrollingList.get_title(history_info.link_url)
      if (requestFailed)
        History.replaceState(history_info, title_text, history_info.link_url)
      else
        push_state = true
        old_state = History.getState();
        if (old_state.data.hasOwnProperty("link_url"))
          push_state = false
          push_state ||= history_info.link_url != old_state.data.link_url
          push_state ||= history_info.scroll_id != old_state.data.scroll_id
        if (push_state)
          History.pushState(history_info, title_text, history_info.link_url)

    $(window).trigger("resize")

  # This function tests to see if the browser supports the History API, and if it does
  # to setup event monitoring needed for history.
  test_for_history:        ->
    @history_supported = History.enabled
    if (@history_supported)
      active_link = $(".scrolling-list-primary .scrolling-list-content .active")
      if (active_link.length > 0)
        active_link = active_link.find("a")
        history_info =
          scroll_id: $(".scrolling-list-primary").attr("id"),
          link_url:  active_link.attr("href"),
          ajax_url:  @contentScrollingList.build_click_link(active_link.attr("href"))
        History.replaceState(history_info, @contentScrollingList.get_title(history_info.link_url),
          history_info.link_url)
      this.window_history = window.History
      $(window).bind("statechange", { bind_object: this }, this.history_changed)

  # This function is called when the page URL changes.
  # it finds out what the URL's ID is and what the ID of the
  # current item on the page is, and if they don't match, makes
  # the scroll list and page match the URL
  history_changed: (eventData) =>
    history_state = History.getState()
    if (history_state.data.hasOwnProperty("link_url"))
      window_id = @contentScrollingList.get_item_link_id(history_state.data.link_url)
      selected_item_id = null
      next_item = null
      scrolling_list = $("#" + history_state.data.scroll_id)
      active_link = $(".scrolling-list-content .active a")

      if (active_link.length > 0)
        selected_item_id = @contentScrollingList.get_item_link_id(active_link.attr("href"))
      else
        if (window_id == "new")
          selected_item_id = "new"
        else
          next_item = scrolling_list.find(".scrolling-next a")
          if (next_item.length > 0)
            selected_item_id = next_item.attr("href").match(/\?id=(\d+|new)/)
            if (selected_item_id)
              selected_item_id = selected_item_id[1]

          next_item = scrolling_list.find(".scrolling-previous a")
          if (next_item.length > 0)
            selected_item_id = next_item.attr("href").match(/\?id=(\d+|new)/)
            if (selected_item_id)
              selected_item_id = selected_item_id[1]

      if (selected_item_id != window_id)
        # The history has changed to something other than what we're displaying now.
        # update it!
        @contentScrollingList.show_item(eventData, $("#" + history_state.data.scroll_id), history_state.data.link_url)

  # This function responds when the scroll load has finished.
  # It performs some cleanup that may be necessary because the scroll is an
  # asynchronous callback loading data and may cause the selection to be changed.
  # So, we may have to set the current item here after the load finishes.
  scroll_finished: (eventData) =>
    scrolling_list = $(eventData.currentTarget)
    search_url = null

    # It is possible for the user to press the forward and back button too fast
    # for the scrolling to keep up with it, so we have to set the selection here sometimes...
    active_item = scrolling_list.find(".active")
    active_item = active_item.closest("li")

    search_url = @scrollingList.build_find_link(window.location.pathname)
    new_active_item = scrolling_list.find("a[href=\"" + search_url + "\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href^=\"" + search_url + "?\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href*=\"" + search_url + "?\"]")

    if (new_active_item.length > 0 && active_item != new_active_item)
      active_item.removeClass("active")
      new_active_item.closest("li").addClass("active")
    else
      if (new_active_item.length <= 0)
        active_item.removeClass("active")

  # Set stuff up after the page loads...
  document_ready: ->
    scrolling_list = $(".scrolling-list-primary")
    content_id = scrolling_list.attr("data-content-id")

    $(document).on("scroll_load_finished", ".scrolling-list-primary", { scroll_class: this }, this.scroll_finished)
    $(document).on("scroll_content_loaded", "#" + content_id, { scroll_class: this }, this.display_content_on_page)

    if (scrolling_list.length > 0)
      this.test_for_history()
      this.adjust_size()

    $(window).resize(=>
      scrolling_list = $(".scrolling-list-primary")
      if (scrolling_list.length > 0)
        this.adjust_size()
    )

root.adminScrollingList = null

$(document).ready( ->
  if (!root.adminScrollingList)
    root.adminScrollingList = new root.ScrollingListAdmin()

  root.adminScrollingList.document_ready()
)