require "spec_helper"

describe MeasuringUnitsController do
  let(:test_user) { FactoryGirl.create(:user, password: "Nobody12") }
  let(:measuring_unit) { MeasuringUnit.first }

  it "shows the measuring units page", js: true do
    visit_page measuring_unit_path(measuring_unit), test_user
    expect(find(".scrolling-list-content")).to have_content(measuring_unit.name)
    expect(find("#menu_measuring_units")).to have_content("Measuring Unit")
    sleep 0.1
  end
end