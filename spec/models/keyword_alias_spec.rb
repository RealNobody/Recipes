require 'spec_helper'

describe KeywordAlias do
  before do
    @keyword_alias = FactoryGirl.build(:keyword_alias)
  end

  subject { @keyword_alias }

  it { should respond_to :keyword_id }
  it { should respond_to :alias }
  it { should respond_to :keyword }
  it { should respond_to(:list_name) }

  describe "basic validation" do
    it { should be_valid }

    it "should not allow a nil alias" do
      @keyword_alias.alias = nil
      @keyword_alias.should_not be_valid
    end

    it "should not allow a blank alias" do
      @keyword_alias.alias = ""
      @keyword_alias.should_not be_valid
    end

    it "should require an keyword" do
      @keyword_alias.keyword_id = nil
      @keyword_alias.should_not be_valid
    end

    it "should require a valid keyword" do
      @keyword_alias.keyword_id = -1
      @keyword_alias.should_not be_valid
    end

    it "should be unique case insensitive" do
      keyword_test = @keyword_alias.clone
      keyword_test.save!
      @keyword_alias.alias = @keyword_alias.alias.upcase

      @keyword_alias.should_not be_valid
    end
  end

  it "should have a list name" do
    @keyword_alias.list_name.should eq(I18n.t("activerecord.keyword_alias.list_name", alias: @keyword_alias.alias, keyword: @keyword_alias.keyword.name))
  end
end