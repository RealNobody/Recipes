require "measuring_unit"

class MeasuringUnitsController < ApplicationController
  before_filter :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @measuring_units = MeasuringUnit.all()

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @measuring_units }
    end
  end

  def new
  end
end
