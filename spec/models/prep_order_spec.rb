require 'spec_helper'

describe PrepOrder do
  before do
    @prep_order = FactoryGirl.build(:prep_order)
  end

  subject { @prep_order }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }
  it { should respond_to(:order) }
  it { should respond_to(:recipes) }

  describe "validation" do
    it "should be valid" do
      @prep_order.should be_valid
    end

    it "should validate name" do
      @prep_order.name = ""
      @prep_order.should_not be_valid
    end
  end

  it "should have recipes" do
    @prep_order.save!()
    recipe_1 = FactoryGirl.create(:recipe, prep_order_id: @prep_order.id)
    @prep_order.recipes.count.should eq 1
    @prep_order.recipes[0].id.should eq recipe_1.id
  end
end