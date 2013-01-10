require "measuring_unit"
require "scrolling_list_helper"

class MeasuringUnitsController < ApplicationController
  include ScrollingListHelper

  before_filter :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @measuring_units = MeasuringUnit.page(1)
    @measuring_unit = @measuring_units [0]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def page
    @measuring_units = MeasuringUnit.page(params[:page])

    respond_to do |format|
      format.html { render(partial: "list", layout: false) }
      format.json { render json: @measuring_units }
    end
  end

  def show
    @measuring_units = MeasuringUnit.page(1)
    @measuring_unit = MeasuringUnit.find(params[:id])

    respond_to do |format|
      format.html { render action: :index }
      format.json { render json: @user }
    end
  end
end
