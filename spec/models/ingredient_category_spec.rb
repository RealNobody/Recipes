require 'spec_helper'

describe IngredientCategory do
  before do
    @ingredient_category = FactoryGirl.build(:ingredient_category)
  end

  subject { @ingredient_category }

  it { should respond_to(:name) }
  it { should respond_to(:order) }

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
