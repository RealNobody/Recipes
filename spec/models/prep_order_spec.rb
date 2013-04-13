require 'spec_helper'

describe PrepOrder do
  before do
    @prep_order = FactoryGirl.build(:prep_order)
  end

  subject { @prep_order }

  it { should respond_to(:name) }
  it { should respond_to(:order) }

  describe "validation" do
    it "should be valid" do
      @prep_order.should be_valid
    end

    it "should validate name" do
      @prep_order.name = ""
      @prep_order.should_not be_valid
    end
  end
end