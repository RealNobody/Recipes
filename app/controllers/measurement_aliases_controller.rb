require "measurement_alias"
require "scrollable_list_controller"

class MeasurementAliasesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:alias,
                             :measuring_unit_id)
    end

    params
  end
end