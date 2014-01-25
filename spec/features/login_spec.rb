require "spec_helper"

describe MeasuringUnitsController do
  describe "Logging into the site" do
    let(:first_item) { MeasuringUnit.index_sort.first }
    let(:test_user) { FactoryGirl.create(:user) }
    let(:page_object) { RecipeRspecApp.full_page(test_user, MeasuringUnit) }

    it "logs into the site", :js do
      page_object.load item_id: first_item.id

      expect(page_object.layout.top_menu.login_state).to have_content(test_user.name)
      expect(page_object.layout.alert_box.alerts.length).to be > 0
      expect(page_object.layout.alert_box.errors.length).to be 0
      expect(page_object.layout.alert_box.notices.length).to be > 0
      expect(page_object.layout.alert_box.notices[0]).to have_content("Signed in successfully")
    end
  end
end