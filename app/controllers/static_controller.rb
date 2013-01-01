class StaticController < ApplicationController
  before_filter :authenticate_user!
end