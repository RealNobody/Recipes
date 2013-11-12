require "ingredient_alias"
require "scrollable_list_controller"

class IngredientAliasesController < ScrollableListController
  def assign_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:alias,
                             :ingredient_id)
    end

    params
  end
end