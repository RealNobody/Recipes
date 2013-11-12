require "measuring_unit"
require "scrollable_list_controller"

class MeasuringUnitsController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:name,
                             :abbreviation,
                             :can_delete)
    end

    params
  end

  def create
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit  = MeasuringUnit.new(permitted_attributes(params[:measuring_unit]))
    if (has_abbreviation != nil)
      @measuring_unit.has_abbreviation = has_abbreviation
    end

    super
  end

  def update
    @measuring_unit  = MeasuringUnit.where(id: params[:id]).first()
    @measuring_unit  ||= MeasuringUnit.new()
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)

    @measuring_unit.assign_attributes(permitted_attributes(params[:measuring_unit]))
    if (has_abbreviation != nil)
      @measuring_unit.has_abbreviation = has_abbreviation
    end

    super
  end
end