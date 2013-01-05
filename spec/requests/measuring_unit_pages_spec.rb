require 'spec_helper'

describe "MeasuringUnit pages" do
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { page }

  describe "list measuring units" do
    before do
      visit_page(measuring_units_path, @user)
    end

    describe "should have a list" do
      it { should have_selector("p", text: "This is a start.")}
    end

    # it "works! (now write some real specs)" do
    #   # # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
    #   # get measuring_units_index_path
    #   # response.status.should be(200)
    # end
  end
end
