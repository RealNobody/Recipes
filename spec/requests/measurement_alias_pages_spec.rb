require 'spec_helper'

describe "MeasurementAlias pages" do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { Capybara.page }

  describe "list measurement alias" do
    before do
      visit_page("#{measurement_aliases_path}?per_page=4", @user)
    end

    describe "should have a list" do
      it { should have_selector("h1", text: "Measurement Aliases") }
      it { should have_selector(".scrolling-list") }
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
            prev_scroll_link.should(match(/\/page\/#{prev_page_loop}\?/))
          end

          prev_page_loop += 1
          page_loop      += 1

          next_scroll_link = get_scroll_link(".scrolling-next a")
          if (next_scroll_link)
            next_scroll_link.should(match(/\/page\/#{page_loop}\?/))
            visit_page(next_scroll_link, @user)
          end
        end while (next_scroll_link != nil)
      end
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