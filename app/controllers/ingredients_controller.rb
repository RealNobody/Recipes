require "ingredient_alias"
require "scrollable_list_controller"

class IngredientsController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:name,
                             :measuring_unit_id,
                             :ingredient_category_id,
                             :prep_instructions,
                             :day_before_prep_instructions)
    end

    params
  end
end