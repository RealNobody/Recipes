require "measuring_unit"
require "scrollable_list_controller"

class SearchAliasesController < ScrollableListController
  def permitted_attributes(params)
    if params.respond_to? (:permit)
      params = params.permit(:alias, :aliased_type, :aliased_id)
    end

    params
  end

  #def create
  #  has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
  #  @measuring_unit  = SearchAlias.new(permitted_attributes(params[:measuring_unit]))
  #  if (has_abbreviation != nil)
  #    @measuring_unit.has_abbreviation = has_abbreviation
  #  end
  #
  #  super
  #end
  #
  #def update
  #  @measuring_unit  = SearchAlias.where(id: params[:id]).first()
  #  @measuring_unit  ||= SearchAlias.new()
  #  has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
  #
  #  @measuring_unit.assign_attributes(permitted_attributes(params[:measuring_unit]))
  #  if (has_abbreviation != nil)
  #    @measuring_unit.has_abbreviation = has_abbreviation
  #  end
  #
  #  super
  #end
end