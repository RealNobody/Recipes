require "measuring_unit"

class MeasuringUnitsController < ApplicationController
  layout false, only: [ :page ]

  before_filter :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @measuring_units = MeasuringUnit.page(1)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def page
    @measuring_units = MeasuringUnit.page(params[:page])

    respond_to do |format|
      format.html # page.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def new
  end
end
