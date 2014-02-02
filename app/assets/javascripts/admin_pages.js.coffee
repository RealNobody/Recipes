root = exports ? this

# This class is responsible for the features of the admin pages.
#
# One feature of the admin pages is th sizing of the detail section tabs.
# The detail tabs are sized to the size of the largest sub-tab, or the height
# of the screen, whichever is larges.
#   NOTE:  I am still playing around with the layout and sizing as I clearly
#          don't know a lot.
#          For example, I don't know how to calculate the size of the tabs until
#          they are clicked on and shown.
#          Fixing this up to be "perfect" is a low priority at best, so for now
#          I just go with what I have.
#
# Another aspect of the admin pages is deleting an item.
# Since the delete action is the same for all administrative items, we handle the code
# for it here.

root.AdminPage = class AdminPage
  constructor: () ->
    @minimum_max_height = 160
    @adminScrollingList = root.adminScrollingList

  # This function adjusts the size of the tabs
  adjust_size: ->
    if (@adminScrollingList)
      recipe_tab = $(".recipe-tab-content")
      size_parent = recipe_tab.closest(".scrolling-content")
      scrolling_list = $(".scrolling-list-primary")
      new_link = $(".scrolling-list-new-link")

      if (size_parent && size_parent.length > 0)
        tab_list = size_parent.find("ul")
        tab_list_height = tab_list.height() + root.RecipeApp.container_margin + 2
        min_size = @adminScrollingList.calculate_min_height() - tab_list_height
        calc_min = this.calculate_tabs_min_height()
        new_link_height = new_link.height() + root.RecipeApp.container_margin
        tab_set = $(".recipe-admin-tabs .recipe-nav-tabs li a")

        if (min_size < calc_min)
          min_size = calc_min

        for tab_item in tab_set
          sub_tab = $($(tab_item).attr("href") + " .recipe-tab-content")
          sub_tab.css("min-height", (min_size).toString() + "px")

          sub_tab_set = sub_tab.find(".recipe-admin-tabs-sub .recipe-nav-tabs-sub li a")
          for sub_tab_item in sub_tab_set
            $(sub_tab_item).attr("href")

        scroll_list_min = parseInt(scrolling_list.css("max-height").replace(/px/, ""))
        if (scroll_list_min < (min_size + tab_list_height - root.RecipeApp.container_margin - new_link_height))
          scrolling_list.addClass("scroll-list-do-not_adjust-height")
          scrolling_list.css("max-height",
                              (min_size + tab_list_height - root.RecipeApp.container_margin - new_link_height).toString() + "px")
        else
          scrolling_list.removeClass("scroll-list-do-not_adjust-height")
        $(scrolling_list.closest(".well")).css("min-height",
                                                  (@adminScrollingList.calculate_min_height() - root.RecipeApp.container_margin - new_link_height).toString() + "px")

  calculate_sub_tabs_min_height: (tab_object) ->
    min_tab_height = 0
    tab_set = tab_object.find(".recipe-admin-tabs-sub .recipe-nav-tabs-sub li a")

    for sub_tab in tab_set
      tab_height = $($(sub_tab).attr("href") + " .recipe-tab-content-sub").height()
      if (tab_height > min_tab_height)
        min_tab_height = tab_height

    min_tab_height

  calculate_tabs_min_height: ->
    min_tab_height = 0
    tab_set = $(".recipe-admin-tabs .recipe-nav-tabs li a")

    for sub_tab in tab_set
      tab_object = $($(sub_tab).attr("href") + " .recipe-tab-content")
      tab_height = tab_object.height()
      if (tab_height > min_tab_height)
        min_tab_height = tab_height
      tab_height = this.calculate_sub_tabs_min_height(tab_object)

    min_tab_height

  # This function handles the click of the delete button.
  # It shows the delete confirmation dialog box.
  delete_item: (eventData) ->
    eventData.preventDefault()

    $("#confirm-delete-dialog").modal()

    false

  # When the user confirms the delete, this performs the delete.
  delete_confirmed: (eventData) ->
    eventData.preventDefault()

    $("#confirm-delete-dialog").modal('hide')

    $.ajax(
      url: window.location.pathname
      type: "post"
      data: { _method: "delete" }
    ).done( ->
      new_location = window.location.pathname

      new_location = new_location.replace(/(\/\d+(?:\?.*)?)$/, "")
      window.location.replace(new_location)
    ).fail( ->
      alert("Delete failed, please try again.")
    )

    false

  # submit_form: function (eventData)
  # {
  #   var admin_page = eventData.data.admin_page

  #   eventData.preventDefault()

  #   var unit_form = $("#measuring_unit form")
  #   var submit_method = unit_form.attr("method")
  #   var submit_data = unit_form.serialize()
  #   var submit_location = unit_form.attr("action")

  #   submit_data += "&ajax_submit=true"
  #   $.ajax({ url: submit_location, type: submit_method, data: submit_data })
  # },

  bind_links: =>
    $(document).off("click", "#delete-admin-item", this.delete_item)
    $(document).off("click", "#confirm-delete", this.delete_confirmed)
    $(document).on("click", "#delete-admin-item", { admin_page: this }, this.delete_item)
    $(document).on("click", "#confirm-delete", { admin_page: this }, this.delete_confirmed)
    $("#delete-admin-item").removeAttr("data-method")
    # $(document).on("click", "#measuring_unit .btn-primary", { admin_page: this }, this.submit_form)

root.adminPage = null

$(document).ready(->
  if (!root.adminPage)
    root.adminPage = new root.AdminPage()

  root.adminPage.adjust_size()
  root.adminPage.bind_links()

  $("*").bind("scroll_content_loaded", { admin_page: adminPage }, root.adminPage.bind_links)

  main_scroll = $(".scrolling-list-primary")

  if (main_scroll.length > 0)
    $(window).bind("resize", { admin_page: root.adminPage }, (eventData) ->
      eventData.data.admin_page.adjust_size()
    )
)