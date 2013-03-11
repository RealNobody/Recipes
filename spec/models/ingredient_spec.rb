require 'spec_helper'

describe Ingredient do
  before(:each) do
    @ingredient = FactoryGirl.build(:ingredient)
  end

  subject { @ingredient }

  it { should respond_to(:name) }
  it { should respond_to(:measuring_unit_id) }
  it { should respond_to(:ingredient_category_id) }
  it { should respond_to(:prep_instructions) }
  it { should respond_to(:day_before_prep_instructions) }
  it { should respond_to(:measuring_unit) }
  it { should respond_to(:ingredient_category) }

  describe "basic validations" do
    it { should be_valid }

    it "should not allow a blank name" do
      @ingredient.name = ""
      @ingredient.should_not be_valid
    end

    it "should not allow a missing category" do
      @ingredient.ingredient_category_id = nil
      @ingredient.should_not be_valid
    end

    it "should not allow an invalid category" do
      @ingredient.ingredient_category_id = -1
      @ingredient.should_not be_valid
    end

    it "should not allow a missing measuring unit" do
      @ingredient.measuring_unit_id = nil
      @ingredient.should_not be_valid
    end

    it "should not allow an invalid measuring unit" do
      @ingredient.measuring_unit_id = -1
      @ingredient.should_not be_valid
    end
  end
end