require 'rails_helper'
require "factory_girl"

RSpec.describe "User Pages", :type => :request do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { Capybara.page }

  describe "GET /user_pages" do
    it do
      visit_page(user_path(@user), @user)
      is_expected.to have_selector("p", text: @user.name)
    end
  end
end
