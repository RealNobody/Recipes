require "measurement_conversion"
require "scrollable_list_controller"

class MeasurementConversionsController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:smaller_measuring_unit_id,
                             :larger_measuring_unit_id,
                             :multiplier)
    end

    params
  end
end