var recipiesApp;

Recipies = function ()
{
};

Recipies.prototype =
{
};

Recipies.Application = function ()
{
};

Recipies.Application.prototype =
{
  last_height: -1,
  last_width: -1,
  header_height: 40,
  footer_height: 60,
  min_height: 120,
  container_margin: 20,

  /*
    I wanted a static floating footer, and to use/test the BootStrap menus.
    Unfortunately, BootStraps navbar is a huge pan in the ass.
    There are 2 different navbars which interact with the page differently.
    So, when the page is sized, we have to deal with them differently.
    Also, the floating footer I want cannot be done with just CSS, so I have
    to size things in JavaScript (here obviously.)
  */
  resize_body: function ()
  {
    this.do_resize_body (false);
  },

  do_resize_body: function (from_button_click)
  {
    header_menu_height = 0;

    menu_showing = $("#recipe-button-menu").hasClass ("in");
    if (from_button_click)
      menu_showing = !menu_showing;

    if (menu_showing)
      adjust_height_value = $("#recipe-button-menu").height ();
    else
      adjust_height_value = 0;

    body_height = $(".recipie-body").height ();
    if ($("#recipe-button-menu-button").is (":hidden"))
    {
      header_menu_height = $("#recipie-main-menu").height ();
      $(".recipie-menu-adjust").css ("margin-top", (header_menu_height + 19).toString () + "px");
    }
    else
    {
      $(".recipie-menu-adjust").css ("margin-top", "0px");
      header_menu_height = this.container_margin + 30;
    }

    window_height = $(window).height () - this.footer_height - this.header_height - 1 - header_menu_height - adjust_height_value;

    if (window_height < this.min_height)
    {
      window_height = this.min_height;
      $(".recipie-footer").removeClass ("recipie-footer-float");
      $(".recipie-footer").addClass ("recipie-footer-static");
      body_height = (this.min_height + this.footer_height).toString ();
    }
    else
    {
      $(".recipie-footer").removeClass ("recipie-footer-static");
      $(".recipie-footer").addClass ("recipie-footer-float");
      body_height = "100%";
    }

    if ($("#recipe-button-menu-button").is (":hidden"))
      body_height = ($(window).height () - header_menu_height - this.header_height - 1).toString ();

    if (body_height === "100%")
    {
      $(".recipie-body").height (body_height);
      $("body").height (body_height);
    }
    else
    {
      if (body_height != $(".recipie-body").height ())
      {
        $(".recipie-body").height (body_height + "px");
        $("body").height (body_height + "px");
      }
    }

    if (window_height != this.last_height)
    {
      // When we hit min_height, the footer just becomes an in-line footer.
      if (window_height == this.min_height)
        $(".recipie-container").height ("auto");
      else
        $(".recipie-container").height (window_height);
    }
  }
};

$(window).resize (
  function ()
  {
    if (!recipiesApp)
      recipiesApp = new Recipies.Application ();
    recipiesApp.resize_body ();
  }
);

$(document).ready (
  function ()
  {
    if (!recipiesApp)
      recipiesApp = new Recipies.Application ();
    recipiesApp.resize_body ();
  }
);

/*
  This function addresses a FireFox bug with BootStrap:
    https://github.com/twitter/bootstrap/issues/793
  As referenced here:
    http://twitter.github.com/bootstrap/javascript.html#buttons
*/
$(document).ready('bootstrap_buttons', function() {
  $('.btn').button('reset');
});

/*
  I don't want the site to look different when the menu buttons are shown
  so I hack some JScript together to acomodate the look/feel I want.
*/
$("#recipe-button-menu-button").click(
  function ()
  {
    if ($("#recipe-button-menu").hasClass ("in"))
    {
      $("#recipe-button-menu").height ("0px");
    }
    else
    {
      $("#recipe-button-menu").height ("auto");
    }

    recipiesApp.do_resize_body (true);
  }
);