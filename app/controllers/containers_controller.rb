require "container"
require "scrollable_list_controller"

class ContainersController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:name)
    end

    params
  end
end