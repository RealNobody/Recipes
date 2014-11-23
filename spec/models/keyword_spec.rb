require 'rails_helper'

RSpec.describe Keyword, :type => :model do
  before do
    @keyword = FactoryGirl.build(:keyword)
  end

  subject { @keyword }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:search_aliases) }

  describe "validation" do
    it "should be valid" do
      expect(@keyword).to be_valid
    end

    it "should validate name" do
      @keyword.name = ""
      expect(@keyword).not_to be_valid
    end
  end

  it "supports validation" do
    @keyword.save!

    expect(@keyword.id).not_to be_nil
  end
end
