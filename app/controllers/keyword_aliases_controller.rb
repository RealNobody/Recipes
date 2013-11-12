require "keyword_alias"
require "scrollable_list_controller"

class KeywordAliasesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:alias,
                             :keyword_id)
    end

    params
  end
end