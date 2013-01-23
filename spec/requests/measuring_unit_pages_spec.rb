require 'spec_helper'

describe "MeasuringUnit pages" do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { Capybara.page }

  describe "list measuring units" do
    before do
      visit_page("#{measuring_units_path}?per_page=4", @user)
    end

    describe "should have a list" do
      it { should have_selector("h1", text: "Measuring Units") }
      it { should have_selector(".scrolling-list") }
    end

    describe "should self paginate" do
      it do
        scroll_link = Capybara.page.find(".scrolling-next a").native.get_attribute("href")
        scroll_link.should(match(/\/page\/2\?/))
        visit_page(scroll_link, @user)
        scroll_link = Capybara.page.find(".scrolling-next a").native.get_attribute("href")
        scroll_link.should(match(/\/page\/3\?/))
      end
    end
  end
end
