require 'spec_helper'

describe Container do
  before do
    @container = FactoryGirl.build(:container)
  end

  subject { @container }

  it { should respond_to(:name) }

  describe "validation" do
    it "should be valid" do
      @container.should be_valid
    end

    it "should validate name" do
      @container.name = ""
      @container.should_not be_valid
    end
  end

  describe "supports validation" do
    @container.save!

    @container.id.should_not be_nil
  end
end