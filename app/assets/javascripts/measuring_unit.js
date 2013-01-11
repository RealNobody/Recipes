//= require recipies

var measuringUnitPage;

Recipies.MeasuringUnitPage = function ()
{
};

Recipies.MeasuringUnitPage.prototype =
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
      measuringUnitPage = new Recipies.MeasuringUnitPage ();

    measuringUnitPage.adjust_size ();
  }
);

$(window).resize (
  function ()
  {
    if (!measuringUnitPage)
      measuringUnitPage = new Recipies.MeasuringUnitPage ();

    measuringUnitPage.adjust_size ();
  }
);