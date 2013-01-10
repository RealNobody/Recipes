$(".scrolling-list").scroll (
  function ()
  {
    scroll_div = $(".scrolling-list");
    next_link = $(".scrolling-list .scrolling-next a");

    if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight () ||
        scroll_div.scrollTop > scroll_div.innerHeight() - 20)
    {
      if (next_link && next_link.length > 0)
      {
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
            scroll_div.find ("ul").append(additional_content);

            if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight ())
            {
              scroll_div.scroll();
            }
          }
        );
      }
    }
  }
);

$(".scrolling-list").ready(
  function ()
  {
    scroll_div = $(".scrolling-list");
    if (scroll_div.get (0).scrollHeight <= scroll_div.innerHeight ())
    {
      scroll_div.scroll();
    }
  }
);