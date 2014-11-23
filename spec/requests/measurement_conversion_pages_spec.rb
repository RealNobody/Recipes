require 'rails_helper'

RSpec.describe "MeasurementConversion pages", :type => :request do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { Capybara.page }

  describe "list measurement conversion list" do
    before do
      visit_page("#{measurement_conversions_path}?per_page=4", @user)
    end

    describe "should have a list" do
      it { is_expected.to have_selector("h1", text: "Measurement Conversions") }
      it { is_expected.to have_selector(".scrolling-list") }
    end

    describe "should self paginate" do
      it "should have multiple pages and we should be able to iterate all of them" do
        prev_scroll_link = nil
        page_loop        = 1
        prev_page_loop   = 0
        next_scroll_link = nil

        begin
          prev_scroll_link = get_scroll_link(".scrolling-previous a")
          if (prev_scroll_link)
            expect(prev_scroll_link).to(match(/\/page\/#{prev_page_loop}\?/))
          end

          prev_page_loop += 1
          page_loop      += 1

          next_scroll_link = get_scroll_link(".scrolling-next a")
          if (next_scroll_link)
            expect(next_scroll_link).to(match(/\/page\/#{page_loop}\?/))
            visit_page(next_scroll_link, @user)
          end
        end while (next_scroll_link != nil)
      end
    end
  end

  describe "list measurement conversion list" do
    it "should gracefully handle an invalid id" do
      visit_page("#{measurement_conversions_path}/999999?per_page=4", @user)
      expect(Capybara.page).to have_selector("h1", text: "Measurement Conversions")
      expect(Capybara.page).to have_selector(".scrolling-list")
    end
  end

  def get_scroll_link(which_link)
    scroll_link = nil
    begin
      scroll_link = Capybara.page.find(which_link).native.get_attribute("href")
    rescue
      # We really don't care about the error, we expect the link to not exist at some point.
    end

    scroll_link
  end
end