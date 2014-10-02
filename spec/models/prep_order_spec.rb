require 'spec_helper'

describe PrepOrder, :type => :model do
  before do
    @prep_order = FactoryGirl.build(:prep_order)
  end

  subject { @prep_order }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:recipes) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@prep_order).to be_valid
    end

    it "should validate name" do
      @prep_order.name = ""
      expect(@prep_order).not_to be_valid
    end
  end

  it "should have recipes" do
    @prep_order.save!()
    recipe_1 = FactoryGirl.create(:recipe, prep_order_id: @prep_order.id)
    expect(@prep_order.recipes.count).to eq 1
    expect(@prep_order.recipes[0].id).to eq recipe_1.id
  end
end