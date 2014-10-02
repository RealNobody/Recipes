require "spec_helper"

describe MeasuringUnitsController, type: :controller do
  let(:test_user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in test_user
  end

  describe "create" do
    it "should ignore the abbreviation if has abbreviation is true" do
      @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit, abbreviation: "fred")
      @test_measuring_unit[:has_abbreviation] = false

      post :create, measuring_unit: @test_measuring_unit

      expect(response).to be_redirect
      expect(response).to redirect_to(measuring_unit_path(assigns(:measuring_unit).id))
      expect(assigns(:measuring_unit)[:abbreviation]).to be_blank
    end
  end

  describe "update" do
    it "should blank the abbreviation if has abbreviation is true" do
      @update_measuring_unit                  = FactoryGirl.create(:measuring_unit, abbreviation: Faker::Name.name)
      @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit)
      @test_measuring_unit[:has_abbreviation] = false

      patch :update,
            id:             @update_measuring_unit.id,
            measuring_unit: @test_measuring_unit

      expect(response).to be_success
      expect(MeasuringUnit.where(id: @update_measuring_unit.id).first[:abbreviation]).to_not be
    end
  end
end