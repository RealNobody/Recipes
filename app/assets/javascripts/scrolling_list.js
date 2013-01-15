//= require recipes
//= history

var scrollingList;

Recipes.ScrollingList = function ()
{
};

Recipes.ScrollingList.prototype =
{
  minimum_max_height  : 160,
  history_supported   : false,
  window_history      : null,

  /*
    We don't do the full list when we load the page.
    So, when the list scrolls, if there is more data, load it...
   */
  list_scrolling: function ()
  {
    var scroll_class = this;

    scroll_div = $(".scrolling-list");
    next_link = $(".scrolling-list .scrolling-next a");

    if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight () ||
        scroll_div.find (".scrolling-list-content").height () - scroll_div.scrollTop () -
          scroll_div.innerHeight () - scroll_div.find (".scrolling-next").height () < 0)
    {
      if (next_link && next_link.length > 0 && !next_link.hasClass ("scrolling-fetching"))
      {
        next_link.addClass ("scrolling-fetching");
        $.ajax (
          {
            url: next_link.attr ("href"),
            dataType: "html"
          }
        )
        .done (
          function (additional_content)
          {
            // remove the old next that was used to get the new page.
            // if there is a new next, it will be in the content that we are
            // appending.
            scroll_div.find (".scrolling-next").remove ();
            scroll_div.find ("ul").append (additional_content);
            scroll_class.bind_scroll_links ();

            if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight ())
            {
              scroll_div.scroll ();
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
            next_link.removeClass ("scrolling-fetching");
          }
        );
      }
    }
  },

  calculate_min_height: function ()
  {
    var top_offset = 0;
    var min_height = 0;
    var debug_height = 0;
    var debug_padding = 10;
    var scroll_list_padding = 2;

    if ($(window).width () < 767)
      return this.minimum_max_height;

    var scrolling_list = $(".scrolling-list");
    var recipe_container = $(".recipe-container");

    var offset_item = scrolling_list;
    // while (offset_item && !offset_item.hasClass ("recipe-container"))
    // {
      top_offset += offset_item.offset ().top;
    //   offset_item = $(offset_item.offsetParent ());
    // }

    var debug_area = $(".debug_dump");
    if (debug_area && debug_area.length > 0)
      debug_height = debug_area.height () + debug_padding;

    min_height = recipe_container.height () - top_offset + recipesApp.container_margin - debug_height - scroll_list_padding;
    if (min_height < this.minimum_max_height)
      min_height = this.minimum_max_height;

    return min_height;
  },

  /*
    I want the list to have a maximum size to make it look nicer, so I have
    to do this through a script because I cannot figure out another way...
   */
  adjust_size: function ()
  {
    var max_height = this.calculate_min_height ();
    var min_height = max_height;

    max_height -= recipesApp.container_margin;

    scrolling_list.css ("max-height", max_height.toString () + "px");
    $(".scrolling-content").css ("min-height", min_height.toString () + "px");

    this.list_scrolling ();
  },

  /*
    A helper function to be used multiple places.
    Given a full URL link, what is the AJAX call for just the item piece?
   */
  build_click_link: function (clicked_href)
  {
    return clicked_href.replace (/((.*?\/)+)/, "$1item/");
  },

  /*
    A helper function for fetching the ID of an item link.
   */
  get_item_link_id: function (link_url)
  {
    var get_id = link_url.match (/\/(\d+)$/);

    if (get_id)
      return get_id [1];

    return null;
  },

  /*
    When an item is clicked, if we can, just get the HTML for the item,
    and then render it on the page.
   */
  click_item: function ()
  {
    var scroll_class;

    if (event.data)
      scroll_class = event.data.scroll_class;
    else
      scroll_class = scrollingList;

    var clicked_item = $(event.currentTarget);

    scroll_class.show_item (scroll_class, clicked_item.attr ("href"));
  },

  /*
    A helper function for showing a specific item that can be used
    by both the history and the click event.
   */
  show_item: function (scroll_class, clicked_item_url)
  {
    event.preventDefault ();

    var item_url = scroll_class.build_click_link (clicked_item_url);
    var item_id = scroll_class.get_item_link_id (item_url);

    if (item_id)
    {
      $.ajax (
        {
          url: item_url,
          dataType: "html"
        }
      )
      .done (
        function (display_content)
        {
          // Set the HTML of the item display.
          $(".scrolling-content").html (display_content);

          // switch the active item in the list.
          $(".scrolling-list .active").removeClass ("active");
          var new_active_item = $(".scrolling-list a[href=\"" + clicked_item_url + "\"]");
          if (new_active_item && new_active_item.length > 0)
            new_active_item.closest ("li").addClass ("active");

          // If there is a "next" link in the scrolling list, update it
          // to set the value of the selected item, so if we refresh the page,
          // or if we scroll and the item isn't currently visible, it will be
          // selected appropriately.
          next_link = $(".scrolling-list .scrolling-next a");
          if (next_link && next_link.length > 0)
          {
            next_link_url = next_link.attr ("href");
            next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + item_id);
            next_link.attr ("href", next_link_url);
          }

          // If the history option is supported, use it to update the title and the URL.
          if (scroll_class.history_supported)
          {
            title_text = null;

            history_info =
            {
              link_url: clicked_item_url,
              ajax_url: item_url
            };

            title_text = scroll_class.get_title (history_info.link_url);
            History.pushState (history_info, title_text, history_info.link_url);
          }
        }
      )
      .fail (
        function ()
        {
          alert ("erik - do something about the fail.");
        }
      );
    }
  },

  /*
    This function gets the title for the information for the item.
    The title comes from a hidden item on the form which contains
    the title for the shown page.
   */
  get_title: function (item_url)
  {
    title_text = null;
    object_type = item_url.match (/\/?([^\/]+)/) [1];
    object_type = object_type.substring (0, object_type.length - 1);
    title_object = $("#" + object_type + "_title");
    if (title_object && title_object.length > 0)
      title_text = title_object.attr ("value");

    return title_text;
  },

  /*
    This function unbinds the click event for all list items, then re-binds them.
    This is necessary because we don't load all items initially, and so when
    the list scrolls and new items are added, we need to bind those items.
   */
  bind_scroll_links: function ()
  {
    $(".scroll-item-link").unbind ("click", this.click_item);
    $(".scroll-item-link").click ({ scroll_class: this }, this.click_item);
  },

  /*
    This is the function that is called when the History object detects that
    the user has moved to a page in our history.

    This simply re-renders the item for the page.
   */
  history_changed: function ()
  {
    var history_state = History.getState ();
    var scroll_class = scrollingList;
    var window_id = scroll_class.get_item_link_id (history_state.data.link_url);
    var selected_item_id;
    var next_item;

    active_link = $(".scrolling-list-content .active a");
    if (active_link && active_link.length > 0)
    {
      selected_item_id = scroll_class.get_item_link_id (active_link.attr ("href"));
    }
    else
    {
      next_item = $(".scrolling-list .scrolling-next a");
      if (next_item && next_item.length > 0)
      {
        selected_item_id = next_item.attr ("href").match (/\?id=(\d+)/);
        if (selected_item_id)
          selected_item_id = selected_item_id [1];
      }
    }

    if (selected_item_id !== window_id)
    {
      // The history has changed to something other than what we're displaying now.
      // update it!
      scroll_class.show_item (scroll_class, history_state.data.link_url);
    }
  },

  /*
    This function tests to see if the browser supports the history functionality.

    If it does, it then sets up the initial history information for the initialy
    displayed item.
   */
  test_for_history: function ()
  {
    var scroll_class = scrollingList;

    // Is history supported by this browser?
    this.history_supported = History.enabled;
    if (this.history_supported)
    {
      active_link = $(".scrolling-list-content .active");
      if (active_link && active_link.length > 0)
      {
        active_link = active_link.find ("a");
        history_info =
        {
          link_url: active_link.attr ("href"),
          ajax_url: scroll_class.build_click_link (active_link.attr ("href"))
        };

        History.replaceState (history_info, this.get_title (history_info.link_url), history_info.link_url);
      }
      this.window_history = window.History;
      History.Adapter.bind (window, 'statechange', this.history_changed);
    }
  }
};

//// The event bindngs for the scrolling class:

$(".scrolling-list").scroll (
  function ()
  {
    if (!scrollingList)
      scrollingList = new Recipes.ScrollingList ();

    scrollingList.list_scrolling ();
  }
);

$(".scrolling-list").ready(
  function ()
  {
    scrolling_list = $(".scrolling-list");
    if (scrolling_list && scrolling_list.length > 0)
    {
      if (!scrollingList)
        scrollingList = new Recipes.ScrollingList ();

      scroll_div = $(".scrolling-list");
      if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight ())
      {
        scroll_div.scroll();
      }
    }
  }
);

$(document).ready (
  function ()
  {
    scrolling_list = $(".scrolling-list");
    if (scrolling_list && scrolling_list.length > 0)
    {
      if (!scrollingList)
        scrollingList = new Recipes.ScrollingList ();

      scrollingList.adjust_size ();
      scrollingList.bind_scroll_links ();
      scrollingList.test_for_history ();
    }
  }
);

$(window).resize (
  function ()
  {
    scrolling_list = $(".scrolling-list");
    if (scrolling_list && scrolling_list.length > 0)
    {
      if (!scrollingList)
        scrollingList = new Recipes.ScrollingList ();

      scrollingList.adjust_size ();
    }
  }
);