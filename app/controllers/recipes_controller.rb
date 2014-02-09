require "scrollable_list_controller"

class RecipesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:name,
                             :recipe_type_id,
                             :servings,
                             :meals,
                             :label_instructions,
                             :prep_order_id,
                             :prep_instructions,
                             :cooking_instructions)
    end

    params
  end
end