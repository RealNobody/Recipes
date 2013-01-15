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
      var recipe_tab = $(".recipe-tab-content");
      var size_parent = recipe_tab.closest (".scrolling-content");
      var scrolling_list = $(".scrolling-list");

      if (size_parent && size_parent.length > 0)
      {
        var tab_list = size_parent.find ("ul");
        var tab_list_height = tab_list.height () + recipesApp.container_margin + 2;
        var min_size = scrollingList.calculate_min_height () - tab_list_height;
        var calc_min = this.calculate_tabs_min_height ();

        if (min_size < calc_min)
          min_size = calc_min;

        $("#measuring_unit").css ("min-height", min_size.toString () + "px");
        $("#aliases").css ("min-height", min_size.toString () + "px");
        $("#conversions").css ("min-height", min_size.toString () + "px");
        $("#ingredients").css ("min-height", min_size.toString () + "px");

        var scroll_list_min = parseInt (scrolling_list.css ("max-height").replace (/px/, ""));
        if (scroll_list_min < (min_size + tab_list_height - recipesApp.container_margin))
        {
          scrolling_list.css ("max-height", (min_size + tab_list_height - recipesApp.container_margin).toString () + "px");
        }
        $(scrolling_list.closest (".well")).css ("min-height", (scrollingList.calculate_min_height () - recipesApp.container_margin).toString () + "px");
      }
    }
    // alert ("adjusting the size now");
  },

  calculate_tabs_min_height: function ()
  {
    var tab_height;
    var min_tab_height = 0;

    tab_height = $("#measuring_unit .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $("#aliases .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $("#conversions .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;
    tab_height = $("#ingredients .recipe-tab-content").height ();
    if (tab_height > min_tab_height)
      min_tab_height = tab_height;

    return min_tab_height;
  }
};

$(document).ready (
  function ()
  {
    if (!measuringUnitPage)
      measuringUnitPage = new Recipes.MeasuringUnitPage ();

    measuringUnitPage.adjust_size ();
  }
);

$(window).resize (
  function ()
  {
    if (!measuringUnitPage)
      measuringUnitPage = new Recipes.MeasuringUnitPage ();

    measuringUnitPage.adjust_size ();
  }
);