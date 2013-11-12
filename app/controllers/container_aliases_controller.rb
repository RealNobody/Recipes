require "container_alias"
require "scrollable_list_controller"

class ContainerAliasesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:alias,
                             :container_id)
    end

    params
  end
end