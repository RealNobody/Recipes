require "measuring_unit"
require "scrolling_list_helper"

class MeasuringUnitsController < ApplicationController
  include ScrollingListHelper

  before_filter :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    setup_instance_variables()

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def page
    setup_instance_variables()

    respond_to do |format|
      format.html { render(partial: "scrolling_list/scroll_content", layout: false) }
      format.json { render json: @measuring_units }
    end
  end

  def item
    setup_instance_variables()

    respond_to do | format |
      format.html { render(partial: "show", layout: false) }
      format.json { render json: @measuring_units }
    end
  end

  def show
    setup_instance_variables()

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @user }
    end
  end

  private
    def setup_instance_variables()
      if (params[:page] == nil)
        @measuring_units = MeasuringUnit.page(params[:page])
      else
        @measuring_units = MeasuringUnit.page(params[:page])
      end
      if (params[:id] == nil)
        @measuring_unit = MeasuringUnit.first()
      else
        @measuring_unit = MeasuringUnit.find(params[:id])
      end
    end
end