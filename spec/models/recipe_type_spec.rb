require 'spec_helper'

describe RecipeType, :type => :model do
  before do
    @recipe_type = FactoryGirl.build(:recipe_type)
  end

  subject { @recipe_type }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:recipes) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@recipe_type).to be_valid
    end

    it "should validate name" do
      @recipe_type.name = ""
      expect(@recipe_type).not_to be_valid
    end
  end

  it "should have recipes" do
    @recipe_type.save!()
    recipe_1 = FactoryGirl.create(:recipe, recipe_type_id: @recipe_type.id)
    expect(@recipe_type.recipes.count).to eq 1
    expect(@recipe_type.recipes[0].id).to eq recipe_1.id
  end
end
