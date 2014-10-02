require 'spec_helper'

describe IngredientCategory, :type => :model do
  before do
    @ingredient_category = FactoryGirl.build(:ingredient_category)
  end

  subject { @ingredient_category }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:ingredients) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@ingredient_category).to be_valid
    end

    it "should validate name" do
      @ingredient_category.name = ""
      expect(@ingredient_category).not_to be_valid
    end
  end
end
