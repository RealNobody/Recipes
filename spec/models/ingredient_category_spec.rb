require 'spec_helper'

describe IngredientCategory do
  before do
    @ingredient_category = FactoryGirl.build(:ingredient_category)
  end

  subject { @ingredient_category }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }
  it { should respond_to(:order) }
  it { should respond_to(:ingredients) }
  it { should respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      @ingredient_category.should be_valid
    end

    it "should validate name" do
      @ingredient_category.name = ""
      @ingredient_category.should_not be_valid
    end
  end
end
