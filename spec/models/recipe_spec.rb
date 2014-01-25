require 'spec_helper'

describe Recipe do
  before do
    @recipe = FactoryGirl.build(:recipe)
  end

  subject { @recipe }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }
  it { should respond_to(:cooking_instructions) }
  it { should respond_to(:label_instructions) }
  it { should respond_to(:meals) }
  it { should respond_to(:prep_instructions) }
  it { should respond_to(:prep_order_id) }
  it { should respond_to(:recipe_type_id) }
  it { should respond_to(:servings) }
  it { should respond_to(:prep_order) }
  it { should respond_to(:recipe_type) }

  describe "validation" do
    it "should be valid" do
      @recipe.should be_valid
    end

    it "should validate name" do
      @recipe.name = ""
      @recipe.should_not be_valid
    end

    it "should allow nil label_instructions" do
      @recipe.label_instructions = nil
      @recipe.should be_valid
    end

    it "should validate cooking instructions or prep_instructions present" do
      @recipe.cooking_instructions = ""
      @recipe.prep_instructions    = ""
      @recipe.should_not be_valid
    end

    it "should allow no prep_instructions if cook_instructions" do
      @recipe.cooking_instructions = Faker::Lorem.paragraphs.join("\n\n")
      @recipe.prep_instructions    = nil
      @recipe.should be_valid
    end

    it "should allow no cook_instructions if prep_instructions" do
      @recipe.prep_instructions    = Faker::Lorem.paragraphs.join("\n\n")
      @recipe.cooking_instructions = nil

      @recipe.should be_valid
    end

    it "should require prep_order" do
      @recipe.prep_order = nil

      @recipe.should_not be_valid
    end

    it "should require recipe_type" do
      @recipe.recipe_type = nil

      @recipe.should_not be_valid
    end

    it "should require valid prep_order" do
      @recipe.prep_order_id = -1
      @recipe.should_not be_valid
    end

    it "should require valid recipe_type" do
      @recipe.recipe_type_id = -1
      @recipe.should_not be_valid
    end

    it "should not allow invalid meal counts" do
      @recipe.meals = -1
      @recipe.should_not be_valid
    end

    it "should not allow invalid servings counts" do
      @recipe.servings = -1
      @recipe.should_not be_valid
    end

    it "should only allow integral meal counts" do
      @recipe.meals = 1.5
      @recipe.should_not be_valid
    end

    it "should not allow integral servings counts" do
      @recipe.servings = 1.5
      @recipe.should_not be_valid
    end
  end
end