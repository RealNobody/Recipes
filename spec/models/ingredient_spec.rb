require 'spec_helper'

describe Ingredient do
  before(:each) do
    @ingredient = FactoryGirl.build(:ingredient)
  end

  subject { @ingredient }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

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

  describe "aliases" do
    before(:each) do
      @alias_text = Faker::Lorem::sentence
      @ingredient.save!()
      @ingredient.add_alias(@alias_text).save!
    end

    it { should be_valid }
  end
end