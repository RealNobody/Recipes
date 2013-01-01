require 'spec_helper'
require "factory_girl"
require "support/login_macros"

describe "User Pages" do
  include LoginMacros

  subject { page }

  describe "GET /user_pages" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit_page(user_path(user), user)
    end

    it do
      should have_selector("p", text: user.name)
    end
  end
end
