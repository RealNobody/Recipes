require "spec_helper"

describe MeasuringUnitsController do
  let(:test_user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in test_user
  end

  describe "create" do
    it "should set the has abbreviation"# do
  #    @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit)
  #    @test_measuring_unit[:has_abbreviation] = false
  #
  #    post :create, measuring_unit: @test_measuring_unit
  #
  #    response.should be_redirect
  #    response.should redirect_to(measuring_unit_path(assigns(:measuring_unit).id))
  #  end
  end

  describe "update" do
    it "should set the has abbreviation"# do
  #    @update_measuring_unit                  = FactoryGirl.create(:measuring_unit, abbreviation: Faker::Name.name)
  #    @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit)
  #    @test_measuring_unit[:has_abbreviation] = false
  #
  #    patch :update,
  #          id:             @update_measuring_unit.id,
  #          measuring_unit: @test_measuring_unit
  #
  #    response.should be_success
  #    #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))
  #  end
  end
end