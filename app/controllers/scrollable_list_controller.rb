class ScrollableListController < ApplicationController
  before_filter do
    authenticate_user!

    @model_class_name = eval("#{self.controller_name.classify}")
    @model_per_page = eval("#{@model_class_name}.default_per_page")
    @selected_item = nil
    @current_page = nil
  end

  # GET /users
  # GET /users.json
  def index
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @current_page }
    end
  end

  def page
    scroll_list_setup_instance_variables(nil)

    respond_to do |format|
      format.html { render(partial: "scrolling_list/scroll_content", layout: false) }
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
      format.html { render(partial: "show", layout: "../scrolling_list/scroll_list_partial", status: item_status) }
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
    scroll_list_setup_instance_variables(eval("#{@model_class_name}.new()"))

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @selected_item }
    end
  end

  #def new_item
  #  scroll_list_setup_instance_variables(MeasuringUnit.new())
  #
  #  respond_to do |format|
  #    format.html { render(partial: "show", layout: "../scrolling_list/scroll_list_partial") }
  #    format.json { render json: @measuring_units }
  #  end
  #end

  def destroy
    @selected_item = eval("#{@model_class_name}.find(params[:id])")
    if (@selected_item && @selected_item.destroy())
      params.delete(:id)
      scroll_list_setup_instance_variables(nil)

      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
    else
      if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
        flash[:error] = @selected_item.errors.full_messages.to_sentence
      else
        flash[:error] = "Could not delete #{@model_class_name.humanize}."
      end
      scroll_list_setup_instance_variables(nil)
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
    end
  end

  def create
    user_item = eval("@#{self.controller_name.singularize}")

    if (user_item == nil)
      scroll_list_setup_instance_variables(eval("#{@model_class_name}.new(params[:#{self.controller_name.singularize}])"))
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
        flash[:error] = "Could not create #{self.controller_name.singularize.humanize}."
      end
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @selected_item }
      end
    end
  end

  def update
    user_item = eval("@#{self.controller_name.singularize}")

    if (user_item == nil)
      scroll_list_setup_instance_variables(nil)

      eval("@selected_item.assign_attributes (params[:#{self.controller_name.singularize}])")
    else
      scroll_list_setup_instance_variables(user_item)
    end

    respond_to do |format|
      if @selected_item.save()
        format.html { render action: :index, notice: t("scrolling_list_controller.update.success", resource_name: self.controller_name.singularize.humanize) }
        format.json { render json: @selected_item }
      else
        if (@selected_item.errors.full_messages && @selected_item.errors.full_messages.length > 0)
          flash[:error] = @selected_item.errors.full_messages.to_sentence
        else
          flash[:error] = t("scrolling_list_controller.update.failure", resource_name: self.controller_name.singularize.humanize)
        end
        format.html { render action: :index }
        format.json { render json: @selected_items.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def scroll_list_setup_instance_variables(new_unit)
    per_page = @model_per_page

    if (params[:per_page] != nil)
      per_page = params[:per_page]
    end
    if (params[:page] == nil)
      @current_page = eval("#{@model_class_name}.page(params[:page]).per(per_page)")
    else
      @current_page = eval("#{@model_class_name}.page(params[:page]).per(per_page)")
    end

    if (new_unit == nil)
      if (params[:id] == nil)
        @selected_item = eval("#{@model_class_name}.first()")
      else
        @selected_item = eval("#{@model_class_name}.where(id: params[:id]).first()")
        @selected_item ||= eval("#{@model_class_name}.new()")
      end
    else
      @selected_item = new_unit
    end

    eval("@#{self.controller_name} = @current_page")
    eval("@#{self.controller_name.singularize} = @selected_item")
  end
end