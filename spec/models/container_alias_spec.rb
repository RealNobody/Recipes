require 'spec_helper'

describe ContainerAlias do
  before do
    @container_alias = FactoryGirl.build(:container_alias)
  end

  subject { @container_alias }

  it { should respond_to :container_id }
  it { should respond_to :alias }
  it { should respond_to :container }
  it { should respond_to(:list_name) }

  describe "basic validation" do
    it { should be_valid }

    it "should not allow a nil alias" do
      @container_alias.alias = nil
      @container_alias.should_not be_valid
    end

    it "should not allow a blank alias" do
      @container_alias.alias = ""
      @container_alias.should_not be_valid
    end

    it "should require an container" do
      @container_alias.container_id = nil
      @container_alias.should_not be_valid
    end

    it "should require a valid container" do
      @container_alias.container_id = -1
      @container_alias.should_not be_valid
    end

    it "should be unique case insensitive" do
      container_test = @container_alias.clone
      container_test.save!
      @container_alias.alias = @container_alias.alias.upcase

      @container_alias.should_not be_valid
    end
  end

  it "should have a list name" do
    @container_alias.list_name.should eq(I18n.t("activerecord.container_alias.list_name", alias: @container_alias.alias, container: @container_alias.container.name))
  end
end