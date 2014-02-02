root = exports ? this

root.RecipeApp = class RecipeApp
  @last_height:      -1
  @last_width:       -1
  @header_height:    40
  @footer_height:    60
  @min_height:       120
  @container_margin: 20

  # I wanted a static floating footer, and to use/test the BootStrap menus.
  # Unfortunately, BootStraps navbar is a huge pan in the ass.
  # There are 2 different navbars which interact with the page differently.
  # So, when the page is sized, we have to deal with them differently.
  # Also, the floating footer I want cannot be done with just CSS, so I have
  # to size things in JavaScript(here obviously.)
  resize_body:       =>
    this.do_resize_body(false)

  # this function does the actual resizing.
  do_resize_body: (from_button_click) ->
    header_menu_height = 0

    menu_showing = $("#recipe-button-menu").hasClass("in")
    if (from_button_click)
      menu_showing = !menu_showing

    if (menu_showing)
      adjust_height_value = $("#recipe-button-menu").height()
    else
      adjust_height_value = 0

    body_height = $(".recipe-body").height()
    if ($("#recipe-button-menu-button").is(":hidden"))
      header_menu_height = $("#recipe-main-menu").height()
      $(".recipe-menu-adjust").css("margin-top", (header_menu_height + 19).toString() + "px")
    else
      $(".recipe-menu-adjust").css("margin-top", "0px")
      header_menu_height = RecipeApp.container_margin + 30

    window_height = $(window).height() - RecipeApp.footer_height - RecipeApp.header_height - 1 - header_menu_height - adjust_height_value

    if (window_height < RecipeApp.min_height)
      window_height = RecipeApp.min_height
      $(".recipe-footer").removeClass("recipe-footer-float")
      $(".recipe-footer").addClass("recipe-footer-static")
      body_height = (RecipeApp.min_height + RecipeApp.footer_height).toString()
    else
      $(".recipe-footer").removeClass("recipe-footer-static")
      $(".recipe-footer").addClass("recipe-footer-float")
      body_height = "100%"

    if ($("#recipe-button-menu-button").is(":hidden"))
      body_height = ($(window).height() - header_menu_height - RecipeApp.header_height - 1).toString()

    if (body_height == "100%")
      $(".recipe-body").height(body_height)
      $("body").height(body_height)
    else
      if (body_height != $(".recipe-body").height())
        $(".recipe-body").height(body_height + "px")
        $("body").height(body_height + "px")

    if (window_height != RecipeApp.last_height)
      # When we hit min_height, the footer just becomes an in-line footer.
      if (window_height == RecipeApp.min_height)
        $(".recipe-container").height("auto")
      else
        $(".recipe-container").height(window_height)

  # I don't want the site to look different when the menu buttons are shown
  # so I hack some JScript together to acomodate the look/feel I want.
  recipe_menu_click: (eventData) ->
    if ($("#recipe-button-menu").hasClass("in"))
      $("#recipe-button-menu").height("0px")
    else
      $("#recipe-button-menu").height("auto")

    eventData.data.recipe_app.do_resize_body(true)

  # Close the flash alert box.
  close_alert: ->
    all_alerts = $(".recipe-error-information .recipe-alert")
    if (! all_alerts || all_alerts.length <= 1)
      $(".recipe-error-information").addClass("recipe-error-hidden")
    $(window).trigger("resize")

  # Setup bindings and perform initialization stuff
  document_ready:    ->
    $(window).resize(this.resize_body)

    $(document).on("click", "#recipe-button-menu-button", { recipe_app: this }, this.recipe_menu_click)
    $(document).on("closed", ".recipe-error-information .recipe-alert", { recipe_app: this }, this.close_alert)

    this.resize_body()

root.recipeApp = null

$(document).ready(->
  if (!root.recipeApp)
    root.recipeApp = new root.RecipeApp()

  root.recipeApp.document_ready()
)

# This function addresses a FireFox bug with BootStrap:
# https://github.com/twitter/bootstrap/issues/793
# As referenced here:
# http://twitter.github.com/bootstrap/javascript.html#buttons
$(document).ready('bootstrap_buttons', ->
  $('.btn').button('reset')
)