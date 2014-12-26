require "scrolling_list_helper"

class ScrollableListController < ApplicationController
  include ScrollingListHelper

  before_filter do
    authenticate_user!

    @model_class          = self.controller_name.classify.constantize
    @parent_obj,
        @parent_relationship,
        @parent_ref_field = get_parent_object()
    @selected_item        = nil
    @current_page         = nil
  end

  # GET /users
  # GET /users.json
  def index
    scroll_list_setup_instance_variables(nil)

    render_full_index(@current_page)
  end

  def page
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html do
        render(partial: "scroll_content",
               layout:  false,
               locals:  { list_item:                @selected_item,
                          list_page:                @current_page,
                          list_params:              params,
                          list_parent_object:       @parent_obj,
                          list_parent_relationship: @parent_relationship })
      end

      format.json { render json: @current_page }
    end
  end

  def item
    scroll_list_setup_instance_variables(nil)
    item_status = 200
    unless (((params[:id] == nil || params[:id] == "new") && @selected_item.id == nil) ||
        (@selected_item.id.to_s() == params[:id]))
      item_status = 404
    end

    render_page_element(@selected_item, item_status)
  end

  def edit
    show
  end

  def show
    scroll_list_setup_instance_variables(nil)

    render_full_index(@selected_item)
  end

  def new
    scroll_list_setup_instance_variables(@model_class.new())

    render_full_index(@selected_item)
  end

  def new_item
    scroll_list_setup_instance_variables(@model_class.new())

    render_page_element(@selected_item)
  end

  def destroy
    @selected_item = @model_class.where(id: params[:id]).first
    if (@selected_item && @selected_item.destroy())
      params.delete(:id)
      scroll_list_setup_instance_variables(nil)

      render_full_index(@selected_item)
    else
      if (@selected_item && @selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
        flash[:error] = @selected_item.errors.full_messages.to_sentence
      else
        flash[:error] = t("scrolling_list_controller.delete.failure", resource_name: @model_class.model_name.human)
      end

      scroll_list_setup_instance_variables(nil)
      render_full_index(@selected_item)
    end
  end

  def create
    user_item = instance_variable_get("@#{self.controller_name.singularize}")

    if (user_item == nil)
      scroll_list_setup_instance_variables(@model_class.new(permitted_attributes(params[self.controller_name.singularize.to_sym])))
    else
      scroll_list_setup_instance_variables(user_item)
    end

    if (@selected_item.save())
      respond_to do |format|
        format.html { redirect_to @selected_item, notice: t("scrolling_list_controller.create.success",
                                                resource_name: @model_class.model_name.human) }
        format.json { render json: @selected_item, status: :created, location: @selected_item }
      end
    else
      if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
        flash[:error] = @selected_item.errors.full_messages.to_sentence
      else
        flash[:error] = t("scrolling_list_controller.create.failure", resource_name: @model_class.model_name.human)
      end

      render_full_index(@selected_item)
    end
  end

  def update
    user_item = instance_variable_get("@#{self.controller_name.singularize}")

    if (user_item == nil)
      scroll_list_setup_instance_variables(nil)

      @selected_item.assign_attributes(permitted_attributes(params[self.controller_name.singularize.to_sym]))
    else
      # I think this is a dead path.
      # I don't remember why it was ever here.  If I ever get here again, I should not
      # why this if/else exists.

      scroll_list_setup_instance_variables(user_item)
    end

    respond_to do |format|
      if @selected_item.save()
        format.html { render action: :index, notice: t("scrolling_list_controller.update.success",
                                                       resource_name: @model_class.model_name.human) }
        format.json { render json: @selected_item }
      else
        if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
          flash[:error] = @selected_item.errors.full_messages.to_sentence
        else
          flash[:error] = t("scrolling_list_controller.update.failure",
                            resource_name: @model_class.model_name.human)
        end

        format.html { render action: :index }
        format.json { render json: @selected_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # Currently we only support 1 level of nested items.
  # If we need to support /measuring_units/33/smaller_measuring_units/22/search_aliases/item/3 (etc.)
  # We'll have to re-visit.  Probably we'll need a new function.
  def get_parent_object
    parent_object   = nil
    parent_id_param = nil

    params.each do |param_name, value|
      if param_name[-3..-1] == "_id"
        parent_route = "/#{param_name[0..-4].pluralize}/#{params[param_name]}/"
        if request.path.start_with?(parent_route)
          parent_object   = param_name[0..-4].classify.constantize.where(id: value).first
          parent_id_param = param_name
          break
        end
      end
    end

    if parent_object
      parent_route      = "/#{parent_object.class.name.tableize}/#{params[parent_id_param]}/"
      relationship_name = @model_class.name.tableize
      if request.path.start_with?(parent_route)
        relationship_name = request.path[parent_route.length..-1].split("/").first
      end
      [parent_object, relationship_name, parent_id_param]
    else
      [nil, nil, nil]
    end
  end

  private
  def scroll_list_setup_instance_variables(new_unit)
    cur_page = params[:page].try(:to_i) || 1
    per_page = params[:per_page].try(:to_i) || @model_class.default_per_page

    if @parent_obj
      @current_page  = @parent_obj.send(@parent_relationship)
      @selected_item = @parent_obj.send(@parent_relationship)
    else
      @current_page  = @model_class
      @selected_item = @model_class
    end

    if (params[:search])
      my_count, @current_page = @model_class.search_alias(params[:search].to_s,
                                                          offset:                 (cur_page - 1) * per_page,
                                                          limit:                  per_page,
                                                          parent_object:          @parent_obj,
                                                          relationship:           @parent_relationship,
                                                          parent_reference_field: @parent_ref_field)

      @current_page ||= []
      unless params[:id]
        @selected_item = @model_class.search_alias(params[:search].to_s,
                                                   offset:                 0,
                                                   limit:                  1,
                                                   parent_object:          @parent_obj,
                                                   relationship:           @parent_relationship,
                                                   parent_reference_field: @parent_ref_field)[1].first
      end

      @current_page.define_singleton_method :current_page do
        cur_page
      end
      @current_page.define_singleton_method :first_page? do
        cur_page <= 1
      end
      @current_page.define_singleton_method :last_page? do
        cur_page >= ((my_count / per_page) + (((my_count % per_page) == 0) ? 0 : 1))
      end
      @current_page.define_singleton_method :next_page do
        cur_page + 1 unless cur_page >= ((my_count / per_page) + (((my_count % per_page) == 0) ? 0 : 1))
      end
      @current_page.define_singleton_method :prev_page do
        cur_page - 1 unless cur_page <= 1
      end
    else
      @current_page  = @current_page.index_sort
      @selected_item = @selected_item.index_sort.limit(1).first

      @current_page = @current_page.page(cur_page).per(per_page)
    end

    if new_unit
      @selected_item = new_unit
    else
      if params[:id]
        @selected_item = @model_class.where(id: params[:id]).first()
      end

      @selected_item ||= @model_class.new()
    end

    instance_variable_set("@#{self.controller_name}", @current_page)
    instance_variable_set("@#{self.controller_name.singularize}", @selected_item)
  end

  def render_full_index(json_item, item_status = 200)
    respond_to do |format|
      format.html { render action: :index, status: item_status }
      format.json { render json: json_item, status: item_status }
    end
  end

  def render_page_element(json_item, item_status = 200)
    respond_to do |format|
      format.html do
        parameters = { partial: "show", layout: "../scrollable_list/scroll_list_partial", status: item_status }
        if (@parent_obj)
          parameters[:partial] = "tab_show"
          parameters[:layout]  = false
          parameters[:locals]  = { show_item: @selected_item }
        end

        render(parameters)
      end
      format.json { render json: json_item, status: item_status }
    end
  end
end