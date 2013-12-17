require "pages/measuring_units_page"
require "pages/scrolling_list_page_page"

class RecipeRspecApp
  @@current_app = nil

  def self.current_instance
    @@current_app ||= RecipeRspecApp.new
  end

  def measuring_units(user)
    @measuring_units ||= MeasuringUnitsPage.new
    @measuring_units.user = user
    @measuring_units
  end

  def scrolling_list_page(user)
    @scrolling_list_page ||= ScrollingListPagePage.new
    @scrolling_list_page.user = user
    @scrolling_list_page
  end
end