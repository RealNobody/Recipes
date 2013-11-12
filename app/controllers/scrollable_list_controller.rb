require "scrolling_list_helper"

class ScrollableListController < ApplicationController
  include ScrollingListHelper

  before_filter do
    authenticate_user!

    @model_class    = self.controller_name.singularize.classify.constantize
    @model_per_page = @model_class.default_per_page
    @selected_item  = nil
    @current_page   = nil
  end

  # GET /users
  # GET /users.json
  def index
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html
      format.json { render json: @current_page }
    end
  end

  def page
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html { render(partial: "scroll_content", layout: false) }
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

    respond_to do |format|
      format.html { render(partial: "show", layout: "../scrollable_list/scroll_list_partial", status: item_status) }
      format.json { render json: @current_page }
    end
  end

  def edit
    show
  end

  def show
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @selected_item }
    end
  end

  def new
    scroll_list_setup_instance_variables(@model_class.new())

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @selected_item }
    end
  end

  def new_item
    scroll_list_setup_instance_variables(@model_class.new())

    respond_to do |format|
      format.html { render(partial: "show", layout: "../scrollable_list/scroll_list_partial") }
      format.json { render json: @measuring_units }
    end
  end

  def destroy
    @selected_item = @model_class.where(id: params[:id]).first
    if (@selected_item && @selected_item.destroy())
      params.delete(:id)
      scroll_list_setup_instance_variables(nil)

      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
    else
      if (@selected_item && @selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
        flash[:error] = @selected_item.errors.full_messages.to_sentence
      else
        flash[:error] = t("scrolling_list_controller.delete.failure", resource_name: self.controller_name.singularize.humanize)
      end
      scroll_list_setup_instance_variables(nil)
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
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
        format.html { redirect_to @selected_item, notice: "#{self.controller_name.singularize.humanize} was successfully created." }
        format.json { render json: @selected_item, status: :created, location: @selected_item }
      end
    else
      if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
        flash[:error] = @selected_item.errors.full_messages.to_sentence
      else
        flash[:error] = t("scrolling_list_controller.create.failure", resource_name: self.controller_name.singularize.humanize)
      end
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
    end
  end

  def update
    user_item = instance_variable_get("@#{self.controller_name.singularize}")

    if (user_item == nil)
      scroll_list_setup_instance_variables(nil)

      @selected_item.assign_attributes(permitted_attributes(params[self.controller_name.singularize.to_sym]))
    else
      scroll_list_setup_instance_variables(user_item)
    end

    respond_to do |format|
      if @selected_item.save()
        format.html { render action: :index, notice: t("scrolling_list_controller.update.success",
                                                       resource_name: self.controller_name.singularize.humanize) }
        format.json { render json: @selected_item }
      else
        if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
          flash[:error] = @selected_item.errors.full_messages.to_sentence
        else
          flash[:error] = t("scrolling_list_controller.update.failure",
                            resource_name: self.controller_name.singularize.humanize)
        end
        format.html { render action: :index }
        format.json { render json: @selected_items.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def scroll_list_setup_instance_variables(new_unit)
    cur_page = params[:page] || 1
    per_page = params[:per_page] || @model_per_page

    @current_page  = @model_class.all
    @selected_item = @model_class.all

    if (params[:search])
      @current_page  = @current_page.search_alias(params[:search].to_s)
      @selected_item = @selected_item.search_alias(params[:search].to_s)
    else
      @current_page  = @current_page.index_sort
      @selected_item = @selected_item.index_sort
    end

    @current_page = @current_page.page(cur_page).per(per_page)
    #@selected_item = @selected_item.page(cur_page).per(per_page)

    if (new_unit == nil)
      if (params[:id] == nil)
        @selected_item = @selected_item.first()
      else
        @selected_item = @model_class.where(id: params[:id]).first()
      end

      @selected_item ||= @model_class.new()
    else
      @selected_item = new_unit
    end

    instance_variable_set("@#{self.controller_name}", @current_page)
    instance_variable_set("@#{self.controller_name.singularize}", @selected_item)
  end
end