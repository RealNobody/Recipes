require "measuring_unit"
require "scrollable_list_controller"

class MeasuringUnitsController < ScrollableListController
  def create
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit  = MeasuringUnit.new(params[:measuring_unit])
    if (has_abbreviation != nil)
      @measuring_unit.has_abbreviation = has_abbreviation
    end

    super
  end

  def update
    @measuring_unit  = MeasuringUnit.find(params[:id])
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit.assign_attributes (params[:measuring_unit])
    if (has_abbreviation != nil)
      @measuring_unit.has_abbreviation = has_abbreviation
    end

    super
  end
end