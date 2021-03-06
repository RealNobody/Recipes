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
      var new_link = $ (".scrolling-list-new-link");

      if (size_parent && size_parent.length > 0)
      {
        var tab_list = size_parent.find ("ul");
        var tab_list_height = tab_list.height () + recipesApp.container_margin + 2;
        var min_size = adminScrollingList.calculate_min_height () - tab_list_height;
        var calc_min = this.calculate_tabs_min_height ();
        var new_link_height = new_link.height () + recipesApp.container_margin;
        var tab_set = $ (".recipe-admin-tabs .recipe-nav-tabs li a");
        var nIndex;
        var sub_tab_set;
        var nSubIndex;
        var sub_tab;

        if (min_size < calc_min)
          min_size = calc_min;

        for (nIndex = tab_set.length - 1; nIndex >= 0; nIndex -= 1)
        {
          sub_tab = $ ($ (tab_set [nIndex]).attr ("href") + " .recipe-tab-content");
          sub_tab.css ("min-height", (min_size).toString () + "px");

          sub_tab_set = sub_tab.find (".recipe-admin-tabs-sub .recipe-nav-tabs-sub li a");
          for (nSubIndex = sub_tab_set.length - 1; nSubIndex >= 0; nSubIndex -= 1)
          {
            $ (sub_tab_set [nSubIndex]).attr ("href");
          }
        }

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

  calculate_sub_tabs_min_height: function (tab_object)
  {
    var tab_height;
    var min_tab_height = 0;
    var tab_set = tab_object.find (".recipe-admin-tabs-sub .recipe-nav-tabs-sub li a")
    var nIndex;

    for (nIndex = tab_set.length - 1; nIndex >= 0; nIndex -= 1)
    {
      tab_height = $ ($ (tab_set [nIndex]).attr ("href") + " .recipe-tab-content-sub").height ();
      if (tab_height > min_tab_height)
        min_tab_height = tab_height;
    }

    return min_tab_height;
  },

  calculate_tabs_min_height: function ()
  {
    var tab_height;
    var min_tab_height = 0;
    var tab_set = $ (".recipe-admin-tabs .recipe-nav-tabs li a")
    var nIndex;
    var tab_object;

    for (nIndex = tab_set.length - 1; nIndex >= 0; nIndex -= 1)
    {
      tab_object = $ ($ (tab_set [nIndex]).attr ("href") + " .recipe-tab-content");
      tab_height = tab_object.height ();
      if (tab_height > min_tab_height)
        min_tab_height = tab_height;
      tab_height = this.calculate_sub_tabs_min_height (tab_object);
    }

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