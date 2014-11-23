require 'rails_helper'

RSpec.describe Recipe, :type => :model do
  before do
    @recipe = FactoryGirl.build(:recipe)
  end

  subject { @recipe }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:cooking_instructions) }
  it { is_expected.to respond_to(:label_instructions) }
  it { is_expected.to respond_to(:meals) }
  it { is_expected.to respond_to(:prep_instructions) }
  it { is_expected.to respond_to(:prep_order_id) }
  it { is_expected.to respond_to(:recipe_type_id) }
  it { is_expected.to respond_to(:servings) }
  it { is_expected.to respond_to(:prep_order) }
  it { is_expected.to respond_to(:recipe_type) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@recipe).to be_valid
    end

    it "should validate name" do
      @recipe.name = ""
      expect(@recipe).not_to be_valid
    end

    it "should allow nil label_instructions" do
      @recipe.label_instructions = nil
      expect(@recipe).to be_valid
    end

    it "should validate cooking instructions or prep_instructions present" do
      @recipe.cooking_instructions = ""
      @recipe.prep_instructions    = ""
      expect(@recipe).not_to be_valid
    end

    it "should allow no prep_instructions if cook_instructions" do
      @recipe.cooking_instructions = Faker::Lorem.paragraphs.join("\n\n")
      @recipe.prep_instructions    = nil
      expect(@recipe).to be_valid
    end

    it "should allow no cook_instructions if prep_instructions" do
      @recipe.prep_instructions    = Faker::Lorem.paragraphs.join("\n\n")
      @recipe.cooking_instructions = nil

      expect(@recipe).to be_valid
    end

    it "should require prep_order" do
      @recipe.prep_order = nil

      expect(@recipe).not_to be_valid
    end

    it "should require recipe_type" do
      @recipe.recipe_type = nil

      expect(@recipe).not_to be_valid
    end

    it "should require valid prep_order" do
      @recipe.prep_order_id = -1
      expect(@recipe).not_to be_valid
    end

    it "should require valid recipe_type" do
      @recipe.recipe_type_id = -1
      expect(@recipe).not_to be_valid
    end

    it "should not allow invalid meal counts" do
      @recipe.meals = -1
      expect(@recipe).not_to be_valid
    end

    it "should not allow invalid servings counts" do
      @recipe.servings = -1
      expect(@recipe).not_to be_valid
    end

    it "should only allow integral meal counts" do
      @recipe.meals = 1.5
      expect(@recipe).not_to be_valid
    end

    it "should not allow integral servings counts" do
      @recipe.servings = 1.5
      expect(@recipe).not_to be_valid
    end
  end
end