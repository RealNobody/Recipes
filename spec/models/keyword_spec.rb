require 'spec_helper'

describe Keyword do
  before do
    @keyword = FactoryGirl.build(:keyword)
  end

  subject { @keyword }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }

  describe "validation" do
    it "should be valid" do
      @keyword.should be_valid
    end

    it "should validate name" do
      @keyword.name = ""
      @keyword.should_not be_valid
    end
  end

  it "supports validation" do
    @keyword.save!

    @keyword.id.should_not be_nil
  end
end
