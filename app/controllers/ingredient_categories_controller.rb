require "ingredient_category"
require "scrollable_list_controller"

class IngredientCategoriesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:name,
                             :order)
    end

    params
  end
end