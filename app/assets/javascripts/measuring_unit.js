//= require recipes

var measuringUnitPage;

Recipes.MeasuringUnitPage = function ()
{
};

Recipes.MeasuringUnitPage.prototype =
{
  adjust_size: function ()
  {
    if (scrollingList)
    {
      var recipe_tab = $ (".recipe-tab-content");
      var size_parent = recipe_tab.closest (".scrolling-content");
      var scrolling_list = $ (".scrolling-list");
      var new_link = $ (".scrolling-list-new-link")

      if (size_parent && size_parent.length > 0)
      {
        var tab_list = size_parent.find ("ul");
        var tab_list_height = tab_list.height () + recipesApp.container_margin + 2;
        var min_size = scrollingList.calculate_min_height () - tab_list_height;
        var calc_min = this.calculate_tabs_min_height ();

        if (min_size < calc_min)
          min_size = calc_min;

        $ ("#measuring_unit").css ("min-height", min_size.toString () + "px");
        $ ("#aliases").css ("min-height", min_size.toString () + "px");
        $ ("#conversions").css ("min-height", min_size.toString () + "px");
        $ ("#ingredients").css ("min-height", min_size.toString () + "px");

        var scroll_list_min = parseInt (scrolling_list.css ("max-height").replace (/px/, ""));
        if (scroll_list_min < (min_size + tab_list_height - recipesApp.container_margin))
        {
          scrolling_list.css ("max-height",
                              (min_size + tab_list_height - recipesApp.container_margin).toString () + "px");
        }
        $ (scrolling_list.closest (".well")).css ("min-height",
                                                  (scrollingList.calculate_min_height () - (2 * recipesApp.container_margin) - new_link.height ()).toString () + "px");
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

  submit_form: function (eventData)
  {
    var bindObject = eventData.data.bind_object;

    event.preventDefault ();

    var unit_form = $ ("#measuring_unit form");
    var submit_method = unit_form.attr ("method");
    var submit_data = unit_form.serialize ();
    var submit_location = unit_form.attr ("action");

    submit_data += "&ajax_submit=true"
    $.ajax ({ url: submit_location, type: submit_method, data: submit_data });
  },

  delete_item: function (eventData)
  {
    var bindObject = eventData.data.bind_object;

    event.preventDefault ();

    var delete_link = $ ("#measuring_unit form a.btn-danger");
    var delete_url = delete_link.attr ("href");

    $.ajax ({ url: delete_url, type: "post", data: { _method: "delete" } });
  },

  bind_form_events: function (eventData)
  {
    var bindObject = eventData.data.bind_object;

    // This should work, and is put here as a backup for when it does work.
    $ ("#measuring_unit .btn-primary").unbind ("click", bindObject.submit_form);
    $ ("#measuring_unit .btn-primary").click ({ bind_object: bindObject }, bindObject.submit_form);
    $ ("#measuring_unit .btn-danger").unbind ("click", bindObject.delete_item);
    $ ("#measuring_unit .btn-danger").click ({ bind_object: bindObject }, bindObject.delete_item);

    // For some reason, this isn't working when the event is called from the scroll click event.
    // I think that something is binding to the button after the page loads, but I really just
    // don't know.  But, by using a timeout, it works.
    setTimeout (
        function ()
        {
          $ ("#measuring_unit .btn-primary").unbind ("click", bindObject.submit_form);
          $ ("#measuring_unit .btn-primary").click ({ bind_object: bindObject }, bindObject.submit_form);
          $ ("#measuring_unit .btn-danger").unbind ("click", bindObject.delete_item);
          $ ("#measuring_unit .btn-danger").click ({ bind_object: bindObject }, bindObject.delete_item);
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