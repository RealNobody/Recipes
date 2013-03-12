require 'spec_helper'

describe IngredientAlias do
  before do
    @ingredient_alias = FactoryGirl.build(:ingredient_alias)
  end

  subject { @ingredient_alias }

  it { should respond_to :ingredient_id }
  it { should respond_to :alias }
  it { should respond_to :ingredient }
  it { should respond_to(:list_name) }

  describe "basic validation" do
    it { should be_valid }

    it "should not allow a nil alias" do
      @ingredient_alias.alias = nil
      @ingredient_alias.should_not be_valid
    end

    it "should not allow a blank alias" do
      @ingredient_alias.alias = ""
      @ingredient_alias.should_not be_valid
    end

    it "should require an ingredient" do
      @ingredient_alias.ingredient_id = nil
      @ingredient_alias.should_not be_valid
    end

    it "should require a valid ingredient" do
      @ingredient_alias.ingredient_id = -1
      @ingredient_alias.should_not be_valid
    end

    it "should be unique case insensitive" do
      ingredient_test = @ingredient_alias.clone
      ingredient_test.save!
      @ingredient_alias.alias = @ingredient_alias.alias.upcase

      @ingredient_alias.should_not be_valid
    end
  end

  it "should have a list name" do
    @ingredient_alias.list_name.should eq(I18n.t("activerecord.ingredient_alias.list_name", alias: @ingredient_alias.alias, ingredient: @ingredient_alias.ingredient.name))
  end
end
