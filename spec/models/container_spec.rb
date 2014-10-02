require 'spec_helper'

describe Container, :type => :model do
  before do
    @container = FactoryGirl.build(:container)
  end

  subject { @container }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@container).to be_valid
    end

    it "should validate name" do
      @container.name = ""
      expect(@container).not_to be_valid
    end
  end

  it "supports validation" do
    @container.save!

    expect(@container.id).not_to be_nil
  end
end