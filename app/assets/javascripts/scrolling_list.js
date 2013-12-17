//= require recipes
//= history

var scrollingList;

Recipes.ScrollingList = function ()
{
};

Recipes.ScrollingList.prototype =
{
  minimum_max_height: 160,
  history_supported:  false,
  window_history:     null,

  should_scroll: function (scroll_div)
  {
    var scroll_info = { scroll_down: false, scroll_up: false, scroll_down_visible: false, scroll_up_visible: false,
      scroll_up_height:              0, scroll_link: null};
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
      if ((scroll_div.get (0).scrollHeight - scroll_next) <= scroll_div.innerHeight () || // There is less than can be seen
          scroll_info.scroll_down_visible)                                                    // The wait can be seen
      {
        scroll_info.scroll_down = true;
      }
    }

    if (!scroll_info.scroll_down)
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

        if (scroll_div.get (0).scrollHeight - scroll_next <= scroll_div.innerHeight () || // There is less than can be seen
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
    if (!cache_pages)
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
        prev_link = $ ("<div class=\"scrolling-previous\"><a href=\"" + prev_link + "\">prev</a></div>");
        delete_height = prev_link.height ();
        $ (scroll_div.find (ul))
      }
    }
  },

  reset_scroll:   function (scroll_div, new_url)
  {
    var scroll_class = this;

    if (!scroll_div.hasClass ("scrolling-fetching"))
    {
      scroll_div.addClass ("scrolling-fetching");

      $.ajax (
          {
            url:      new_url,
            dataType: "html"
          }
      )
          .done (
          function (new_content)
          {
            $ (scroll_div.find ("ul")).html (new_content);
            scroll_class.fire_scroll (scroll_div);
          }
      )
//          .fail (
//          function ()
//          {
//            alert ("erik - do something about the fail.");
//          }
//      )
          .always (
          function ()
          {
            scroll_div.trigger ("scroll_load_finished")

            scroll_div.removeClass ("scrolling-fetching");
          }
      );
    }
  },

  /*
   We don't do the full list when we load the page.
   So, when the list scrolls, if there is more data, load it...
   */
  list_scrolling: function (scroll_div)
  {
    var scroll_class = this;

    if (!scroll_div.hasClass ("scrolling-fetching"))
    {
      scroll_div.addClass ("scrolling-fetching");

      var scroll_info = scroll_class.should_scroll (scroll_div);

      if (scroll_info.scroll_up || scroll_info.scroll_down)
      {
        $.ajax (
            {
              url:      scroll_info.scroll_link.attr ("href"),
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
                if (!search_link || search_link.length <= 0)
                  search_link = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
              }

              if (!search_link || search_link.length <= 0)
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
                {
                  scroll_div.find ("ul").append (add_content.html ());
                }

                scroll_div.trigger ("scroll_items_changed")

                var new_scroll_info = scroll_class.should_scroll (scroll_div);

                if (scroll_info.scroll_down_visible &&
                    new_scroll_info.scroll_up_visible && !new_scroll_info.scroll_down_visible)
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
//            .fail (
//            function ()
//            {
//              alert ("erik - do something about the fail.");
//            }
//        )
            .always (
            function ()
            {
              scroll_div.trigger ("scroll_load_finished")

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

  fire_scroll:     function (scroll_div)
  {
    var scroll_class = this;

    setTimeout (function ()
        {
          $ (scroll_div).trigger ("scroll");
        },
        5
    );
  },

  /*
   A helper function to be used multiple places.
   Given a full URL link, what is the call for a new item.
   */
  build_find_link: function (clicked_href)
  {
    var query_pos = clicked_href.indexOf ("?");

    if (query_pos >= 0)
      clicked_href = clicked_href.substr (0, query_pos);
    if (clicked_href.substr (clicked_href.length - 1) == "/")
      clicked_href = clicked_href.substr(0, clicked_href.length - 1);
    if (clicked_href.substr (clicked_href.length - 5) == "/edit")
      clicked_href = clicked_href.substr(0, clicked_href.length - 5);

    return clicked_href;
  },

  scroll_event: function (eventData)
  {
    var scroll_class = eventData.data.scroll_class;

    scroll_class.list_scrolling ($ (eventData.currentTarget));
  },

  bind_elements: function ()
  {
    $ (".scrolling-list").unbind ("scroll", this.scroll_event);
    $ (".scrolling-list").bind ("scroll", { scroll_class: this }, this.scroll_event);
  },

  document_ready: function ()
  {
    var scroll_class = this;
    var scrolling_list = $ (".scrolling-list");

    if (scrolling_list && scrolling_list.length > 0)
    {
      var scroll_next;
      var scroll_div;

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

          if (scroll_div.get (0).scrollHeight > scroll_next && (scroll_div.get (0).scrollHeight - scroll_next) <= scroll_div.innerHeight ())
          {
            scroll_class.fire_scroll (scroll_div);
          }
        }
      }
    }

    this.bind_elements ();
  }
};

$ (document).ready (
    function ()
    {
      if (!scrollingList)
        scrollingList = new Recipes.ScrollingList ();

      scrollingList.document_ready ();
    }
);