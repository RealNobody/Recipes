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

    it "should allow multiple aliases to be added to an ingredient" do
      alias_count = @ingredient.ingredient_aliases.count
      added_alias = @ingredient.add_alias(Faker::Lorem.sentence)
      added_alias.save!
      added_alias = @ingredient.add_alias(Faker::Lorem.sentence)
      added_alias.save!

      @ingredient.ingredient_aliases.count.should eq(alias_count + 2)
    end

    it "should have default aliases" do
      @ingredient.ingredient_aliases.count.should eq (3)
    end

    it "should have the name as a default aliases" do
      @ingredient.save!()
      Ingredient.find_by_alias(@ingredient.name.upcase).id.should eq(@ingredient.id)
    end

    it "should find ingredients by aliases case insensitive" do
      found_ingredient = Ingredient.find_by_alias(@alias_text.upcase)

      found_ingredient.id.should eq(@ingredient.id)
    end

    it "should not allow an alias to be added for two ingredients" do
      alt_ingredient = FactoryGirl.create(:ingredient)

      alt_ingredient.add_alias(@alias_text).should eq(nil)
    end

    it "should not allow duplicate ingredients by alias case insensitive" do
      alt_ingredient = FactoryGirl.build(:ingredient, name: @alias_text.upcase)

      alt_ingredient.should_not be_valid
    end
  end
end