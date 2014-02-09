require 'spec_helper'

describe RecipeType do
  before do
    @recipe_type = FactoryGirl.build(:recipe_type)
  end

  subject { @recipe_type }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }
  it { should respond_to(:recipes) }
  it { should respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      @recipe_type.should be_valid
    end

    it "should validate name" do
      @recipe_type.name = ""
      @recipe_type.should_not be_valid
    end
  end

  it "should have recipes" do
    @recipe_type.save!()
    recipe_1 = FactoryGirl.create(:recipe, recipe_type_id: @recipe_type.id)
    @recipe_type.recipes.count.should eq 1
    @recipe_type.recipes[0].id.should eq recipe_1.id
  end
end
