//= require recipes

var adminPage;

Recipes.AdminPage = function ()
{
};

Recipes.AdminPage.prototype =
{
  adjust_size: function ()
  {
    if (adminScrollingList)
    {
      var recipe_tab = $ (".recipe-tab-content");
      var size_parent = recipe_tab.closest (".scrolling-content");
      var scrolling_list = $ (".scrolling-list-primary");
      var new_link = $ (".scrolling-list-new-link")

      if (size_parent && size_parent.length > 0)
      {
        var tab_list = size_parent.find ("ul");
        var tab_list_height = tab_list.height () + recipesApp.container_margin + 2;
        var min_size = adminScrollingList.calculate_min_height () - tab_list_height;
        var calc_min = this.calculate_tabs_min_height ();
        var new_link_height = new_link.height () + recipesApp.container_margin;

        if (min_size < calc_min)
          min_size = calc_min;

        $ ("#measuring_unit").css ("min-height", (min_size).toString () + "px");
        $ ("#aliases").css ("min-height", min_size.toString () + "px");
        $ ("#conversions").css ("min-height", min_size.toString () + "px");
        $ ("#ingredients").css ("min-height", min_size.toString () + "px");

        var scroll_list_min = parseInt (scrolling_list.css ("max-height").replace (/px/, ""));
        if (scroll_list_min < (min_size + tab_list_height - recipesApp.container_margin - new_link_height))
        {
          scrolling_list.addClass ("scroll-list-do-not_adjust-height");
          scrolling_list.css ("max-height",
                              (min_size + tab_list_height - recipesApp.container_margin - new_link_height).toString () + "px");
        }
        else
        {
          scrolling_list.removeClass ("scroll-list-do-not_adjust-height");
        }
        $ (scrolling_list.closest (".well")).css ("min-height",
                                                  (adminScrollingList.calculate_min_height () - recipesApp.container_margin - new_link_height).toString () + "px");
      }
    }
  },

  calculate_tabs_min_height: function ()
  {
    var tab_height;
    var min_tab_height = 0;

    tab_height = $ ("#measuring_unit .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $ ("#aliases .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $ ("#conversions .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $ ("#ingredients .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;

    return min_tab_height;
  },

  delete_item: function (eventData)
  {
    var admin_page = eventData.data.admin_page;
    eventData.preventDefault ();

    $ ("#confirm-delete-dialog").modal ();
  },

  delete_confirmed: function (eventData)
  {
    var admin_page = eventData.data.admin_page;
    eventData.preventDefault ();

    $ ("#confirm-delete-dialog").modal ('hide');

    $.ajax ({url: window.location.pathname, type: "post", data: { _method: "delete" }})
        .done (
        function ()
        {
          var new_location = window.location.pathname;

          new_location = new_location.replace (/(\/\d+(?:\?.*)?)$/, "");
          window.location.replace (new_location);
        }
    )
        .fail (
        function ()
        {
          alert ("Delete failed, please try again.");
        }
    );
  },

  // submit_form: function (eventData)
  // {
  //   var admin_page = eventData.data.admin_page;

  //   eventData.preventDefault ();

  //   var unit_form = $ ("#measuring_unit form");
  //   var submit_method = unit_form.attr ("method");
  //   var submit_data = unit_form.serialize ();
  //   var submit_location = unit_form.attr ("action");

  //   submit_data += "&ajax_submit=true"
  //   $.ajax ({ url: submit_location, type: submit_method, data: submit_data });
  // },

  bind_links: function (eventData)
  {
    var admin_page = eventData.data.admin_page;

    $ ("#delete-admin-item").unbind ("click", admin_page.delete_item);
    $ ("#delete-admin-item").bind ("click", { admin_page: admin_page }, admin_page.delete_item);
    $ ("#delete-admin-item").removeAttr ("data-method");

    $ ("#confirm-delete").unbind ("click", admin_page.delete_confirmed);
    $ ("#confirm-delete").bind ("click", { admin_page: admin_page }, admin_page.delete_confirmed);

    // $ ("#measuring_unit .btn-primary").unbind ("click", this.submit_form);
    // $ ("#measuring_unit .btn-primary").click ({ admin_page: this }, this.submit_form);
  }
};

$ (document).ready (
    function (eventData)
    {
      if (! adminPage)
        adminPage = new Recipes.AdminPage ();

      adminPage.adjust_size ();
      adminPage.bind_links ({ data: { admin_page: adminPage } });

      $ ("*").bind ("scroll_content_loaded", { admin_page: adminPage },
                    adminPage.bind_links);

      var main_scroll = $ (".scrolling-list-primary");

      if (main_scroll && main_scroll.length > 0)
      {
        $ (window).bind ("resize", { admin_page: adminPage },
                         function (eventData)
                         {
                           var admin_page = eventData.data.admin_page;
                           admin_page.adjust_size ();
                         }
        );
      }
    }
);