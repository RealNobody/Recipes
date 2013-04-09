require 'spec_helper'

describe RecipeType do
  before do
    @recipe_type = FactoryGirl.build(:recipe_type)
  end

  subject { @recipe_type }

  it { should respond_to(:name) }

  describe "validation" do
    it "should be valid" do
      @recipe_type.should be_valid
    end

    it "should validate name" do
      @recipe_type.name = ""
      @recipe_type.should_not be_valid
    end
  end
end
