//= require recipes
//= history
//= scrolling_list

var adminScrollingList;

Recipes.ScrollingList.Admin = function ()
{
};

Recipes.ScrollingList.Admin.prototype =
{
  calculate_min_height: function ()
  {
    var top_offset = 0;
    var min_height = 0;
    var debug_height = 0;
    var debug_padding = 10;
    var scroll_list_padding = 2;

    if ($ (window).width () < 767)
      return this.minimum_max_height;

    var scrolling_list = $ (".scrolling-list-primary");
    var recipe_container = $ (".recipe-container");

    var offset_item = scrolling_list;
    // while (offset_item && !offset_item.hasClass ("recipe-container"))
    // {
    top_offset += offset_item.offset ().top;
    //   offset_item = $(offset_item.offsetParent ());
    // }

    var debug_area = $ (".debug_dump");
    if (debug_area && debug_area.length > 0)
      debug_height = debug_area.height () + debug_padding;

    min_height = recipe_container.height () - top_offset + recipesApp.container_margin - debug_height -
        scroll_list_padding;
    if (min_height < this.minimum_max_height)
      min_height = this.minimum_max_height;

    return min_height;
  },

  /*
   I want the list to have a maximum size to make it look nicer, so I have
   to do this through a script because I cannot figure out another way...
   */
  adjust_size         : function ()
  {
    var max_height = this.calculate_min_height ();
    var min_height = max_height;
    var scrolling_list = $ (".scrolling-list-primary");
    var new_link = $ (".scrolling-list-new-link");

    max_height -= recipesApp.container_margin;

    if (! scrolling_list.hasClass ("scroll-list-do-not_adjust-height"))
    {
      scrolling_list.css ("max-height",
                          (max_height - new_link.height () - recipesApp.container_margin).toString () + "px");
    }

    this.content_object (scrolling_list).css ("min-height", min_height.toString () + "px");

    scrollingList.list_scrolling (scrolling_list);
  },

  content_object  : function (scroll_div)
  {
    var content_id = scroll_div.attr ("data-content-id");
    var content_obj = $ ("#" + content_id);

    return content_obj;
  },

  /*
   A helper function to be used multiple places.
   Given a full URL link, what is the AJAX call for just the item piece?
   */
  build_click_link: function (clicked_href)
  {
    return clicked_href.replace (/((?:.*?\/)+)/, "$1item/");
  },

  /*
   A helper function to be used multiple places.
   Given a full URL link, what is the call for a new item.
   */
  build_new_link  : function (clicked_href)
  {
    return clicked_href.replace (/((?:.*?\/)+)\d+/, "$1new");
  },

  /*
   A helper function for fetching the ID of an item link.
   */
  get_item_link_id: function (link_url)
  {
    var get_id = link_url.match (/\/(\d+)(?:\?.*)?$/);

    if (get_id)
      return get_id [1];

    get_id = link_url.match (/\/(new$)/);
    if (get_id)
      return get_id [1];

    return null;
  },

  /*
   When an item is clicked, if we can, just get the HTML for the item,
   and then render it on the page.
   */
  click_item      : function (eventData)
  {
    var scroll_class = eventData.data.scroll_class;
    var clicked_item = $ (eventData.currentTarget);
    var scroll_div = clicked_item.closest (".scrolling-list-primary");

    scroll_class.show_item (eventData, scroll_div, clicked_item.attr ("href"));
  },

  click_new_item: function (eventData)
  {
    var scroll_class = eventData.data.scroll_class;
    var clicked_item = $ (eventData.currentTarget);
    var scrolling_div = clicked_item.closest (".scrolling-list-container");

    scrolling_div = scrolling_div.find (".scrolling-list-primary");
    clicked_item = clicked_item.find ("a");

    scroll_class.show_item (eventData, scrolling_div, clicked_item.attr ("href"));
  },

  display_content_on_page: function (scroll_div, display_content, item_url, clicked_item_url, item_id, replaceURL)
  {
    var scroll_content = this.content_object (scroll_div);

    // Set the HTML of the item display.
    scroll_content.html (display_content);

    // switch the active item in the list.
    scroll_div.find (".active").removeClass ("active");
    var search_url = scrollingList.build_find_link (clicked_item_url);
    var new_active_item = scroll_div.find ("a[href=\"" + search_url + "\"]");
    if (! new_active_item || new_active_item.length <= 0)
      new_active_item = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
    if (new_active_item && new_active_item.length > 0)
      new_active_item.closest ("li").addClass ("active");

    // If there is a "next" link in the scrolling list, update it
    // to set the value of the selected item, so if we refresh the page,
    // or if we scroll and the item isn't currently visible, it will be
    // selected appropriately.
    var next_link = scroll_div.find (".scrolling-next a");
    var next_link_url;

    if (next_link && next_link.length > 0)
    {
      next_link_url = next_link.attr ("href");
      next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + item_id);
      next_link.attr ("href", next_link_url);
    }

    next_link = scroll_div.find (".scrolling-previous a");

    if (next_link && next_link.length > 0)
    {
      next_link_url = next_link.attr ("href");
      next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + item_id);
      next_link.attr ("href", next_link_url);
    }

    // If the history option is supported, use it to update the title and the URL.
    if (this.history_supported)
    {
      title_text = null;

      history_info =
      {
        scroll_id: scroll_div.attr ("id"),
        link_url : clicked_item_url,
        ajax_url : item_url
      };

      title_text = this.get_title (history_info.link_url);
      if (replaceURL)
        History.replaceState (history_info, title_text, history_info.link_url);
      else
        History.pushState (history_info, title_text, history_info.link_url);
    }

    scroll_content.trigger ("scroll_content_loaded");
    $ (window).trigger ("resize");
  },

  /*
   A helper function for showing a specific item that can be used
   by both the history and the click event.
   */
  show_item              : function (eventData, scroll_div, clicked_item_url)
  {
    var scroll_class = this;
    var item_url = scroll_class.build_click_link (clicked_item_url);
    var item_id = scroll_class.get_item_link_id (item_url);

    eventData.preventDefault ();

    if (item_id)
    {
      $.ajax (
          {
            url     : item_url,
            dataType: "html"
          }
      )
          .done (
          function (display_content)
          {
            scroll_class.display_content_on_page (scroll_div, display_content, item_url, clicked_item_url, item_id,
                                                  false);
          }
      )
          .fail (
          function (xHeader, status_info, error_Thrown)
          {
            // if the request fails with a 404, then it will return an empty record.
            if (xHeader.status === 404)
            {
              var new_url = scroll_class.build_new_link (clicked_item_url);
              item_url = scroll_class.build_click_link (new_url);
              item_id = "new"
              scroll_class.display_content_on_page (scroll_div, xHeader.responseText, item_url, new_url, item_id, true);
            }
            else
            {
              alert ("erik - do something about the fail.");
            }
          }
      );
    }
  },

  /*
   This function gets the title for the information for the item.
   The title comes from a hidden item on the form which contains
   the title for the shown page.
   */
  get_title              : function (item_url)
  {
    title_text = null;
    object_type = item_url.match (/\/?([^\/]+)/) [1];
    object_type = object_type.substring (0, object_type.length - 1);
    title_object = $ ("#" + object_type + "-title");
    if (title_object && title_object.length > 0)
      title_text = title_object.attr ("value");

    return title_text;
  },

  /*
   This function unbinds the click event for all list items, then re-binds them.
   This is necessary because we don't load all items initially, and so when
   the list scrolls and new items are added, we need to bind those items.
   */
  bind_scroll_links      : function ()
  {
    $ (".scrolling-list-primary .scroll-item-link").unbind ("click", this.click_item);
    $ (".scrolling-list-primary .scroll-item-link").click ({ scroll_class: this }, this.click_item);
    $ (".scrolling-list-new-link").unbind ("click", this.click_new_item);
    $ (".scrolling-list-new-link").click ({ scroll_class: this }, this.click_new_item);
  },

  /*
   This is the function that is called when the History object detects that
   the user has moved to a page in our history.

   This simply re-renders the item for the page.
   */
  history_changed        : function (eventData)
  {
    var history_state = History.getState ();

    if (history_state.data.hasOwnProperty ("link_url"))
    {
      var scroll_class = eventData.data.bind_object;
      var window_id = scroll_class.get_item_link_id (history_state.data.link_url);
      var selected_item_id;
      var next_item;
      var scroll_div = $ ("#" + history_state.data.scroll_id);

      var active_link = $ (".scrolling-list-content .active a");
      if (active_link && active_link.length > 0)
      {
        selected_item_id = scroll_class.get_item_link_id (active_link.attr ("href"));
      }
      else
      {
        if (window_id === "new")
        {
          selected_item_id = "new";
        }
        else
        {
          next_item = scroll_div.find (".scrolling-next a");
          if (next_item && next_item.length > 0)
          {
            selected_item_id = next_item.attr ("href").match (/\?id=(\d+)/);
            if (selected_item_id)
              selected_item_id = selected_item_id [1];
          }

          next_item = scroll_div.find (".scrolling-previous a");
          if (next_item && next_item.length > 0)
          {
            selected_item_id = next_item.attr ("href").match (/\?id=(\d+)/);
            if (selected_item_id)
              selected_item_id = selected_item_id [1];
          }
        }
      }

      if (selected_item_id !== window_id)
      {
        // The history has changed to something other than what we're displaying now.
        // update it!
        scroll_class.show_item (eventData, $ ("#" + history_state.data.scroll_id), history_state.data.link_url);
      }
    }
  },

  /*
   This function tests to see if the browser supports the history functionality.

   If it does, it then sets up the initial history information for the initialy
   displayed item.
   */
  test_for_history       : function ()
  {
    var scroll_class = this;

    // Is history supported by this browser?
    this.history_supported = History.enabled;
    if (this.history_supported)
    {
      active_link = $ (".scrolling-list-content .active");
      if (active_link && active_link.length > 0)
      {
        active_link = active_link.find ("a");
        history_info =
        {
          scroll_id: $ (".scrolling-list-primary").attr ("id"),
          link_url : active_link.attr ("href"),
          ajax_url : scroll_class.build_click_link (active_link.attr ("href"))
        };

        History.replaceState (history_info, this.get_title (history_info.link_url), history_info.link_url);
      }
      this.window_history = window.History;
      $ (window).bind ("statechange", {bind_object: this}, this.history_changed);
    }
  },

  scroll_items_added: function (eventData)
  {
    var scroll_class = eventData.data.admin_scroll_class;

    scroll_class.bind_scroll_links ();
  },

  scroll_finished: function (eventData)
  {
    var scroll_div = $(eventData.currentTarget);
    var search_url;

    // It is possible for the user to press the forward and back button too fast
    // for the scrolling to keep up with it, so we have to set the selection here sometimes...
    scroll_div.find (".active").removeClass ("active");
    search_url = scrollingList.build_find_link (window.location.pathname);
    var new_active_item = scroll_div.find ("a[href=\"" + search_url + "\"]");
    if (! new_active_item || new_active_item.length <= 0)
      new_active_item = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
    if (new_active_item && new_active_item.length > 0)
      new_active_item.closest ("li").addClass ("active");
  },

  document_ready: function ()
  {
    var scroll_class = this;
    var scrolling_list = $ (".scrolling-list-primary");

    scrolling_list.bind ("scroll_items_changed", { admin_scroll_class: this }, this.scroll_items_added)
    scrolling_list.bind ("scroll_load_finished", { admin_scroll_class: this }, this.scroll_finished)

    if (scrolling_list && scrolling_list.length > 0)
    {
      var scroll_next;
      var scroll_div;

      scroll_class.test_for_history ();
      scroll_class.adjust_size ();
      scroll_class.bind_scroll_links ();
    }

    //// The event bindings for the scrolling class:
    $ (window).resize (
        function ()
        {
          var scrolling_list = $ (".scrolling-list-primary");
          if (scrolling_list && scrolling_list.length > 0)
          {
            scroll_class.adjust_size ();
          }
        }
    );
  }
}

$ (document).ready (
    function ()
    {
      if (! adminScrollingList)
        adminScrollingList = new Recipes.ScrollingList.Admin ();

      adminScrollingList.document_ready ();
    }
);