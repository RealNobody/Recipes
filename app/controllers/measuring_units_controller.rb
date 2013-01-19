require "measuring_unit"
require "scrolling_list_helper"

class MeasuringUnitsController < ApplicationController
  include ScrollingListHelper

  before_filter :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    setup_instance_variables(nil)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def page
    setup_instance_variables(nil)

    respond_to do |format|
      format.html { render(partial: "scrolling_list/scroll_content", layout: false) }
      format.json { render json: @measuring_units }
    end
  end

  def item
    setup_instance_variables(nil)

    respond_to do |format|
      format.html { render(partial: "show", layout: false) }
      format.json { render json: @measuring_units }
    end
  end

  #def new_item
  #  setup_instance_variables(MeasuringUnit.new())
  #
  #  respond_to do |format|
  #    format.html { render(partial: "show", layout: false) }
  #    format.json { render json: @measuring_units }
  #  end
  #end

  def edit
    show
  end

  def show
    setup_instance_variables(nil)

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @measuring_unit }
    end
  end

  def new
    setup_instance_variables(MeasuringUnit.new())

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @measuring_unit }
    end
  end

  def create
    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    setup_instance_variables(MeasuringUnit.new(params[:measuring_unit]))
    @measuring_unit.has_abbreviation = has_abbreviation

    if (@measuring_unit.save())
      respond_to do |format|
        format.html { redirect_to @measuring_unit, notice: 'Measuring Unit was successfully created.' }
        format.json { render json: @measuring_unit, status: :created, location: @measuring_unit }
      end
    else
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @measuring_unit }
      end
    end
  end

  def update
    setup_instance_variables(nil)

    has_abbreviation = params[:measuring_unit].delete(:has_abbreviation)
    @measuring_unit.assign_attributes (params[:measuring_unit])
    @measuring_unit.has_abbreviation = has_abbreviation

    respond_to do |format|
      if @measuring_unit.save()
        format.html { render action: :index, notice: 'User was successfully updated.' }
        format.json { render json: @measuring_unit }
      else
        format.html { render action: :index }
        format.json { render json: @measuring_units.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @measuring_unit = MeasuringUnit.find(params[:id])
    if (@measuring_unit && @measuring_unit.destroy())
      params.delete(:id)
      setup_instance_variables(nil)

      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @measuring_unit }
      end
    else
      setup_instance_variables(nil)
      respond_to do |format|
        format.html { render action: :index }
        format.json { render json: @measuring_unit }
      end
    end
  end

  private
  def setup_instance_variables(new_unit)
    per_page = MeasuringUnit.default_per_page
    if (params[:per_page] != nil)
      per_page = params[:per_page]
    end
    if (params[:page] == nil)
      @measuring_units = MeasuringUnit.page(params[:page]).per(per_page)
    else
      @measuring_units = MeasuringUnit.page(params[:page]).per(per_page)
    end

    if (new_unit == nil)
      if (params[:id] == nil)
        @measuring_unit = MeasuringUnit.first()
      else
        @measuring_unit = MeasuringUnit.where(id: params[:id]).first()
        @measuring_unit ||= MeasuringUnit.new()
      end
    else
      @measuring_unit = new_unit
    end
  end
end