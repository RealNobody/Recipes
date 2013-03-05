//= require recipes

var measuringUnitPage;

Recipes.MeasuringUnitPage = function ()
{
};

Recipes.MeasuringUnitPage.prototype =
{
  check_has_abbreviation: function (eventData)
  {
    abbreviation_text = $ ("#measuring_unit .measuring-unit-abbreviation");
    abbreviation_check = $ ("#measuring_unit .measuring-unit-has-abbreviation");
    abbreviation_text.prop ("disabled", ! abbreviation_check.is (":checked"));
  },

  bind_links: function (eventData)
  {
    var mu_page = eventData.data.mu_page;

    $ ("#measuring_unit .measuring-unit-has-abbreviation").unbind ("click", mu_page.check_has_abbreviation);
    $ ("#measuring_unit .measuring-unit-has-abbreviation").bind ("click", { mu_page: mu_page },
                                                                 mu_page.check_has_abbreviation);
  }
};

$ (document).ready (
    function ()
    {
      if (! measuringUnitPage)
        measuringUnitPage = new Recipes.MeasuringUnitPage ();

      measuringUnitPage.bind_links ({ data: { mu_page: measuringUnitPage } });
      $ ("*").bind ("scroll_content_loaded", { mu_page: measuringUnitPage },
                    measuringUnitPage.bind_links);
    }
);