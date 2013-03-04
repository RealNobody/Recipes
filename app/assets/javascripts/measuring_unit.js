//= require recipes

var measuringUnitPage;

Recipes.MeasuringUnitPage = function ()
{
};

Recipes.MeasuringUnitPage.prototype =
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
    // alert ("adjusting the size now");
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

  check_has_abbreviation: function ()
  {
    abbreviation_text = $ ("#measuring_unit .measuring-unit-abbreviation");
    abbreviation_check = $ ("#measuring_unit .measuring-unit-has-abbreviation");
    abbreviation_text.prop ("disabled", ! abbreviation_check.is (":checked"));
  },

  // submit_form: function (eventData)
  // {
  //   var bindObject = eventData.data.bind_object;

  //   eventData.preventDefault ();

  //   var unit_form = $ ("#measuring_unit form");
  //   var submit_method = unit_form.attr ("method");
  //   var submit_data = unit_form.serialize ();
  //   var submit_location = unit_form.attr ("action");

  //   submit_data += "&ajax_submit=true"
  //   $.ajax ({ url: submit_location, type: submit_method, data: submit_data });
  // },

  delete_item: function (eventData)
  {
    var bindObject = eventData.data.bind_object;
    eventData.preventDefault ();

    $ ("#confirm-delete-dialog").modal ();
  },

  delete_confirmed: function (eventData)
  {
    var bindObject = eventData.data.bind_object;
    eventData.preventDefault ();

    $ ("#confirm-delete-dialog").modal ('hide');

    $.ajax ({url: window.location.pathname, type: "post", data: { _method: "delete" }})
        .done (
        function ()
        {
          window.location.replace ("/measuring_units");
        }
    )
        .fail (
        function ()
        {
          alert ("Delete failed, please try again.");
        }
    );
  },

  bind_links: function (bindObject)
  {
    $ ("#measuring_unit .measuring-unit-has-abbreviation").unbind ("click", this.check_has_abbreviation);
    $ ("#measuring_unit .measuring-unit-has-abbreviation").click ({ bind_object: this },
                                                                  this.check_has_abbreviation);

    // $ ("#measuring_unit .btn-primary").unbind ("click", this.submit_form);
    // $ ("#measuring_unit .btn-primary").click ({ bind_object: this }, this.submit_form);

    $ ("#delete-recipe").unbind ("click", this.delete_item);
    $ ("#delete-recipe").click ({ bind_object: this }, this.delete_item);
    $ ("#delete-recipe").removeAttr ("data-method");

    $ ("#confirm-delete").unbind ("click", this.delete_confirmed);
    $ ("#confirm-delete").click ({ bind_object: this }, this.delete_confirmed);
  },

  bind_form_events: function (eventData)
  {
    var bindObject = eventData.data.bind_object;

    // This should work, and is put here as a backup for when it does work.
    bindObject.bind_links ();

    // For some reason, this isn't working when the event is called from the scroll click event.
    // I think that something is binding to the button after the page loads, but I really just
    // don't know.  But, by using a timeout, it works.
    setTimeout (
        function ()
        {
          bindObject.bind_links ();
        },
        5
    );
  }
};

$ (document).ready (
    function ()
    {
      if (! measuringUnitPage)
        measuringUnitPage = new Recipes.MeasuringUnitPage ();

      measuringUnitPage.adjust_size ();
      measuringUnitPage.bind_form_events ({ data: { bind_object: measuringUnitPage } });
      $ ("#scroll-content-measuring_units").bind ("scroll_content_loaded", { bind_object: measuringUnitPage },
                                                  measuringUnitPage.bind_form_events);
    }
);

$ (window).resize (
    function ()
    {
      if (! measuringUnitPage)
        measuringUnitPage = new Recipes.MeasuringUnitPage ();

      measuringUnitPage.adjust_size ();
    }
);