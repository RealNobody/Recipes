//= require recipes
//= history

var scrollingList;

Recipes.ScrollingList = function ()
{
};

Recipes.ScrollingList.prototype =
{
  minimum_max_height: 160,
  history_supported : false,
  window_history    : null,

  should_scroll: function (scroll_div)
  {
    var scroll_info = { scroll_down: false, scroll_up: false, scroll_down_visible: false, scroll_up_visible: false,
      scroll_up_height             : 0, scroll_link: null};
    var scroll_next = scroll_div.find (".scrolling-next");

    if (scroll_next && scroll_next.length > 0)
    {
      scroll_info.scroll_link = $ (scroll_next.find ("a"));
      scroll_next = scroll_next.height ();
    }
    else
    {
      scroll_next = $ (scroll_div.find ("ul li:last-child")).height ();
      scroll_info.scroll_down_visible = scroll_div.find (".scrolling-list-content").height () -
          scroll_div.scrollTop () - scroll_div.innerHeight () - scroll_next < 0;
      scroll_next = 0;
    }

    if (scroll_info.scroll_link && scroll_info.scroll_link.length > 0)
    {
      scroll_info.scroll_down_visible = scroll_div.find (".scrolling-list-content").height () -
          scroll_div.scrollTop () - scroll_div.innerHeight () - scroll_next < 0;

      // There is a next link
      if ((scroll_div.get (0).scrollHeight - scroll_next) <= scroll_div.innerHeight () ||     // There is less than can be seen
          scroll_info.scroll_down_visible)                                                    // The wait can be seen
      {
        scroll_info.scroll_down = true;
      }
    }

    if (! scroll_info.scroll_down)
    {
      scroll_next = scroll_div.find (".scrolling-previous");
      scroll_info.scroll_link = $ (scroll_next.find ("a"));

      if (scroll_next && scroll_next.length > 0)
      {
        scroll_info.scroll_link = $ (scroll_next.find ("a"));
        scroll_next = scroll_next.height ();
      }
      else
      {
        scroll_next = 0;
      }

      if (scroll_info.scroll_link && scroll_info.scroll_link.length > 0)
      {
        scroll_info.scroll_up_height = scroll_next;
        scroll_info.scroll_up_visible = scroll_div.scrollTop () < scroll_next;

        if (scroll_div.get (0).scrollHeight - scroll_next <= scroll_div.innerHeight () ||   // There is less than can be seen
            scroll_info.scroll_up_visible)                                                  // The wait can be seen
        {
          scroll_info.scroll_up = true;
        }
      }
    }

    return scroll_info;
  },

  scrub_unseen_pages: function (scroll_div)
  {
    var cache_pages = scroll_div.attr ("data-cache-pages");

    // $($(".scroll-page-break")[2]).offset().top + $($(".scroll-page-break")[2]).height() - $(".scrolling-list").offset().top
    if (! cache_pages)
      cache_pages = 0;
    else
      cache_pages = parseInt (cache_pages);

    var page_markers = scroll_div.find (".scroll-page-break");

    if (page_markers.length > cache_pages)
    {
      var top_page_index = cache_pages;
      var div_offset = scroll_div.offset ().top;
      var delete_item;
      var page_item;
      var delete_height;

      while ($ (page_markers [top_page_index]).offset ().top + $ (page_markers [top_page_index]).height () - div_offset <= 0)
      {
        top_page_index += 1;
      }
      top_page_index -= 1;

      if (top_page_index >= cache_pages)
      {
        page_item = $ (page_markers [top_page_index]).attr ("data-page");
        delete_item = $ (scroll_div.find ("li:first"));
        while (delete_item.attr ("data-page") != page_item)
        {
          delete_height = delete_item.height ();
          delete_item.remove ();
          scroll_div.scrollTop (scroll_div.scrollTop () - delete_height);
          delete_item = $ (scroll_div.find ("li:first"));
        }
        delete_height = delete_item.height ();
        var prev_link = delete_item.attr ("data-prev_link");
        delete_item.remove ();
        scroll_div.scrollTop (scroll_div.scrollTop () - delete_height);
        prev_link = $("<div class=\"scrolling-previous\"><a href=\"" + prev_link + "\">prev</a></div>");
        delete_height = prev_link.height ();
        $(scroll_div.find(ul))
      }
    }
  },

  /*
   We don't do the full list when we load the page.
   So, when the list scrolls, if there is more data, load it...
   */
  list_scrolling    : function (scroll_div)
  {
    var scroll_class = this;

    if (! scroll_div.hasClass ("scrolling-fetching"))
    {
      scroll_div.addClass ("scrolling-fetching");

      var scroll_info = scroll_class.should_scroll (scroll_div);

      if (scroll_info.scroll_up || scroll_info.scroll_down)
      {
        $.ajax (
            {
              url     : scroll_info.scroll_link.attr ("href"),
              dataType: "html"
            }
        )
            .done (
            function (additional_content)
            {
              var add_content = $ ('<div/>').html (additional_content);
              var search_link = add_content.find ("li a");
              var scroll_down_class = ".scrolling-next";
              var scroll_up_class = ".scrolling-previous";

              if (scroll_info.scroll_up)
              {
                scroll_up_class = ".scrolling-next";
                scroll_down_class = ".scrolling-previous";
              }

              add_content.find (scroll_up_class).remove ();

              // I don't know why, but when going forward and back, the system caches
              // some of the links, so I have to check if they are already there...
              // NOTE:  This probably doesn't work as intended any more...
              if (search_link && search_link.length > 0)
              {
                var search_url;

                search_link = $ (search_link [0]).attr ("href");

                search_url = scroll_class.build_find_link (search_link);
                search_link = scroll_div.find ("a[href=\"" + search_url + "\"]");
                if (! search_link || search_link.length <= 0)
                  search_link = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
              }

              if (! search_link || search_link.length <= 0)
              {
                var hide_scroll_up = scroll_info.scroll_up;

                // remove the old next that was used to get the new page.
                // if there is a new next, it will be in the content that we are
                // appending.
                scroll_div.find (scroll_down_class).remove ();

                if (scroll_info.scroll_up)
                {
                  var scroll_cur = $ (scroll_div.find ("ul li:first-child"));
                  var scroll_offset = 0;
                  scroll_div.find ("ul").prepend (add_content.html ());
                  scroll_cur = scroll_cur.prev ();
                  while (scroll_cur && scroll_cur.length > 0)
                  {
                    scroll_offset += scroll_cur.height ();
                    scroll_cur = scroll_cur.prev ();
                  }
                  scroll_div.scrollTop (scroll_div.scrollTop () + scroll_offset);
                }
                else
                  scroll_div.find ("ul").append (add_content.html ());
                scroll_class.bind_scroll_links ();

                var new_scroll_info = scroll_class.should_scroll (scroll_div);

                if (scroll_info.scroll_down_visible &&
                    new_scroll_info.scroll_up_visible && ! new_scroll_info.scroll_down_visible)
                {
                  // scroll the window up to hide the scroll-up if necessary/possible.
                  var scroll_amount = scroll_div.get (0).scrollHeight - scroll_div.innerHeight ();
                  if (scroll_amount > new_scroll_info.scroll_up_height)
                    scroll_amount = new_scroll_info.scroll_up_height;

                  scroll_div.scrollTop (scroll_amount);

                  new_scroll_info = scroll_class.should_scroll (scroll_div);
                }

                if (new_scroll_info.scroll_down || new_scroll_info.scroll_up)
                {
                  if (new_scroll_info.scroll_link && new_scroll_info.scroll_link.length > 0)
                  {
                    scroll_class.fire_scroll (scroll_div);
                  }
                }
              }
              else
              {
                // one or more links on this page are already on the page
                // set the next page and scroll...
                var new_next_scroll_link = add_content.find (scroll_down_class);

                scroll_div.find (scroll_down_class).remove ();
                scroll_div.find ("ul").append (new_next_scroll_link);

                scroll_class.fire_scroll (scroll_div);
              }
            }
        )
            .fail (
            function ()
            {
              alert ("erik - do something about the fail.");
            }
        )
            .always (
            function ()
            {
              var search_url;

              // It is possible for the user to press the forward and back button too fast
              // for the scrolling to keep up with it, so we have to set the selection here sometimes...
              scroll_div.find (".active").removeClass ("active");
              search_url = scroll_class.build_find_link (window.location.pathname);
              var new_active_item = scroll_div.find ("a[href=\"" + search_url + "\"]");
              if (! new_active_item || new_active_item.length <= 0)
                new_active_item = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
              if (new_active_item && new_active_item.length > 0)
                new_active_item.closest ("li").addClass ("active");

              scroll_div.removeClass ("scrolling-fetching");
            }
        );
      }
      else
      {
        scroll_div.removeClass ("scrolling-fetching");
      }
    }
    else
    {
      // a scroll is processing, try again later...
      scroll_class.fire_scroll (scroll_div);
    }
  },

  fire_scroll         : function (scroll_div)
  {
    var scroll_class = this;

    setTimeout (function ()
                {
                  scroll_class.list_scrolling (scroll_div);
                },
                5
    );
  },

  // This is for the "master" scrolling list only, so we use scrolling-list-primary
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

  // This is for the "master" scrolling list only, so we use scrolling-list-primary
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

    this.list_scrolling (scrolling_list);
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
   A helper function to be used multiple places.
   Given a full URL link, what is the call for a new item.
   */
  build_find_link : function (clicked_href)
  {
    var query_pos = clicked_href.indexOf ("?");

    if (query_pos >= 0)
      clicked_href = clicked_href.substr (0, query_pos);

    return clicked_href;
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
    var clicked_item = $ (event.currentTarget);
    var scroll_div = clicked_item.closest (".scrolling-list");

    scroll_class.show_item (scroll_div, clicked_item.attr ("href"));
  },

  click_new_item: function (eventData)
  {
    var scroll_class = eventData.data.scroll_class;
    var clicked_item = $ (event.currentTarget);
    var scrolling_div = clicked_item.closest ("scrolling-list-container");

    scrolling_div = scrolling_div.find (".scrolling-list");
    clicked_item = clicked_item.find ("a");

    scroll_class.show_item (scrolling_div, clicked_item.attr ("href"));
  },

  display_content_on_page: function (scroll_div, display_content, item_url, clicked_item_url, replaceURL)
  {
    var scroll_content = this.content_object (scroll_div);

    // Set the HTML of the item display.
    scroll_content.html (display_content);

    // switch the active item in the list.
    scroll_div.find (".active").removeClass ("active");
    var search_url = this.build_find_link (clicked_item_url);
    var new_active_item = scroll_div.find ("a[href=\"" + search_url + "\"]");
    if (! new_active_item || new_active_item.length <= 0)
      new_active_item = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
    if (new_active_item && new_active_item.length > 0)
      new_active_item.closest ("li").addClass ("active");

    // If there is a "next" link in the scrolling list, update it
    // to set the value of the selected item, so if we refresh the page,
    // or if we scroll and the item isn't currently visible, it will be
    // selected appropriately.
    next_link = scroll_div.find (".scrolling-next a");
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
  show_item              : function (scroll_div, clicked_item_url)
  {
    var scroll_class = this;
    var item_url = scroll_class.build_click_link (clicked_item_url);
    var item_id = scroll_class.get_item_link_id (item_url);

    event.preventDefault ();

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
            scroll_class.display_content_on_page (scroll_div, display_content, item_url, clicked_item_url, false);
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
              scroll_class.display_content_on_page (scroll_div, xHeader.responseText, item_url, new_url, true);
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
    $ (".scroll-item-link").unbind ("click", this.click_item);
    $ (".scroll-item-link").click ({ scroll_class: this }, this.click_item);
    $ (".scrolling-list-new-link").unbind ("click", this.click_new_item);
    $ (".scrolling-list-new-link").click ({ scroll_class: this }, this.click_new_item);
  },

  // This is primarily for the master scroll, but may work with sub-scrolls...

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

      active_link = $ (".scrolling-list-content .active a");
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
        }
      }

      if (selected_item_id !== window_id || window_id === "new")
      {
        // The history has changed to something other than what we're displaying now.
        // update it!
        scroll_class.show_item ($ ("#" + history_state.data.scroll_id), history_state.data.link_url);
      }
    }
  },

  // This is only for the master scroll, so we use scrolling-list-primary.
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

  document_ready: function ()
  {
    var scroll_class = this;
    var scrolling_list = $ (".scrolling-list");

    if (scrolling_list && scrolling_list.length > 0)
    {
      var scroll_next;
      var scroll_div;

      scroll_class.test_for_history ();
      scroll_class.adjust_size ();
      scroll_class.bind_scroll_links ();

      if (scrolling_list && scrolling_list.length > 0)
      {
        var scroll_index;
        for (scroll_index = scrolling_list.length - 1; scroll_index >= 0; scroll_index -= 1)
        {
          scroll_div = $ (scrolling_list[scroll_index])
          scroll_next = scroll_div.find (".scrolling-next");

          if (scroll_next && scroll_next.length > 0)
            scroll_next = scroll_next.height ();
          else
            scroll_next = 0;

          if ((scroll_div.get (0).scrollHeight - scroll_next) <= scroll_div.innerHeight ())
          {
            scroll_class.fire_scroll (scroll_div);
          }
        }
      }
    }

    //// The event bindngs for the scrolling class:
    $ (window).resize (
        function ()
        {
          var scrolling_list = $ (".scrolling-list");
          if (scrolling_list && scrolling_list.length > 0)
          {
            scroll_class.adjust_size ();
          }
        }
    );

    $ (".scrolling-list").scroll (
        function ()
        {
          scroll_class.list_scrolling ($ (event.currentTarget));
        }
    );
  }
}
;

$ (document).ready (
    function ()
    {
      if (! scrollingList)
        scrollingList = new Recipes.ScrollingList ();

      scrollingList.document_ready ();
    }
);