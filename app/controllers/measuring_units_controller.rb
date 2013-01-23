require "measuring_unit"
require "scrolling_list_helper"
require "scrollable_list_controller"

class MeasuringUnitsController < ScrollableListController
  include ScrollingListHelper

  def create
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit = MeasuringUnit.new(params[:measuring_unit])
    @measuring_unit.has_abbreviation = has_abbreviation

    super
  end

  def update
    @measuring_unit = MeasuringUnit.find(params[:id])
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit.assign_attributes (params[:measuring_unit])
    @measuring_unit.has_abbreviation = has_abbreviation

    super
  end
end