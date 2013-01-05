require 'spec_helper'
require "factory_girl"

describe "User Pages" do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { page }

  describe "GET /user_pages" do
    it do
      visit_page(user_path(@user), @user)
      should have_selector("p", text: @user.name)
    end
  end
end
