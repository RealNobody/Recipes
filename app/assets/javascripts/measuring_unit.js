//= require recipes

var measuringUnitPage;

Recipes.MeasuringUnitPage = function ()
{
};

Recipes.MeasuringUnitPage.prototype =
{
  adjust_size: function ()
  {
    // alert ("adjusting the size now");
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