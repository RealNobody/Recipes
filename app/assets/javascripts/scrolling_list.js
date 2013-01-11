//= require recipies

var scrollingList;

Recipies.ScrollingList = function ()
{
};

Recipies.ScrollingList.prototype =
{
  minimum_max_height: 120,

  list_scrolling: function ()
  {
    scroll_class = this;

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

  adjust_size: function ()
  {
    top_offset = 0;
    max_height = 0;

    scrolling_list = $(".scrolling-list");
    recipie_container = $(".recipie-container");

    offset_item = scrolling_list;
    while (offset_item && !offset_item.hasClass ("recipie-container"))
    {
      top_offset += offset_item.offset ().top;
      offset_item = $(offset_item.offsetParent ());
    }

    max_height = recipie_container.height () - top_offset + recipiesApp.container_margin;
    if (max_height < this.minimum_max_height)
      max_height = this.minimum_max_height;

    scrolling_list.css ("max-height", max_height.toString () + "px");
    $(".scrolling-content").css ("min-height", (max_height + (2 * recipiesApp.container_margin)).toString () + "px");
    this.list_scrolling ();
  },

  click_item: function (event_item)
  {
    clicked_item = $(event_item.currentTarget);
    event_item.preventDefault ();

    item_url = clicked_item.attr ("href");
    item_url = item_url.replace (/((.*?\/)+)/, "$1item/");

    item_id = item_url.match (/\/(\d+)$/);

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
          $(".scrolling-list .active").removeClass ("active");
          $(".scrolling-content").html (display_content);
          clicked_item.closest ("li").addClass ("active");

          next_link = $(".scrolling-list .scrolling-next a");
          if (next_link && next_link.length > 0)
          {
            next_link_url = next_link.attr ("href");
            next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + item_id [1]);
            next_link.attr ("href", next_link_url);
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

  bind_scroll_links: function ()
  {
    $(".scroll-item-link").unbind ("click");

    $(".scroll-item-link").click (
      function ()
      {
        scrollingList.click_item (event);
      }
    );
  }
};

$(".scrolling-list").scroll (
  function ()
  {
    if (!scrollingList)
      scrollingList = new Recipies.ScrollingList ();

    scrollingList.list_scrolling ();
  }
);

$(".scrolling-list").ready(
  function ()
  {
    if (!scrollingList)
      scrollingList = new Recipies.ScrollingList ();

    scroll_div = $(".scrolling-list");
    if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight ())
    {
      scroll_div.scroll();
    }
  }
);

$(document).ready (
  function ()
  {
    if (!scrollingList)
      scrollingList = new Recipies.ScrollingList ();

    scrollingList.adjust_size ();
    scrollingList.bind_scroll_links ();
  }
);

$(window).resize (
  function ()
  {
    if (!scrollingList)
      scrollingList = new Recipies.ScrollingList ();

    scrollingList.adjust_size ();
  }
);