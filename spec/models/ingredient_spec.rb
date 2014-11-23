require 'rails_helper'

RSpec.describe Ingredient, :type => :model do
  before(:each) do
    @ingredient = FactoryGirl.build(:ingredient)
  end

  subject { @ingredient }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:measuring_unit_id) }
  it { is_expected.to respond_to(:ingredient_category_id) }
  it { is_expected.to respond_to(:prep_instructions) }
  it { is_expected.to respond_to(:day_before_prep_instructions) }
  it { is_expected.to respond_to(:measuring_unit) }
  it { is_expected.to respond_to(:ingredient_category) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "basic validations" do
    it { is_expected.to be_valid }

    it "should not allow a blank name" do
      @ingredient.name = ""
      expect(@ingredient).not_to be_valid
    end

    it "should not allow a missing category" do
      @ingredient.ingredient_category_id = nil
      expect(@ingredient).not_to be_valid
    end

    it "should not allow an invalid category" do
      @ingredient.ingredient_category_id = -1
      expect(@ingredient).not_to be_valid
    end

    it "should not allow a missing measuring unit" do
      @ingredient.measuring_unit_id = nil
      expect(@ingredient).not_to be_valid
    end

    it "should not allow an invalid measuring unit" do
      @ingredient.measuring_unit_id = -1
      expect(@ingredient).not_to be_valid
    end
  end

  describe "aliases" do
    before(:each) do
      @alias_text = Faker::Lorem::sentence
      @ingredient.save!()
      @ingredient.add_alias(@alias_text).save!
    end

    it { is_expected.to be_valid }
  end
end