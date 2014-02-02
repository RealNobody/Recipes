root = exports ? this

# This class takes care of the JavaScript needed for the Measuring Unit
# administrative edit page.
#
# The only thing needed is that when the checkbox on the page is checked
# the default abreviation is enabled, and when it is unchecked, it is disabled.

root.MeasuringUnitPage = class MeasuringUnitPage
  check_has_abbreviation: (eventData) ->
    abbreviation_text = $("#measuring_unit .measuring-unit-abbreviation")
    abbreviation_check = $("#measuring_unit .measuring-unit-has-abbreviation")
    abbreviation_text.prop("disabled", !abbreviation_check.is(":checked"))

  document_ready: ->
    $(document).on("click", "#measuring_unit .measuring-unit-has-abbreviation", { mu_page: this }, this.check_has_abbreviation)

root.measuringUnit = null

$(document).ready( ->
  if (!root.measuringUnit)
    root.measuringUnit = new root.MeasuringUnitPage()

  root.measuringUnit.document_ready()
)