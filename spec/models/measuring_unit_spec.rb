# == Schema Information
#
# Table name: measuring_units
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  abreviation :string(255)
#  search_name :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'
require 'faker'

describe MeasuringUnit do
  before do
    @measuring_unit = MeasuringUnit.new(name: "Test Cup")
  end

  subject { @measuring_unit }

  it { should respond_to(:name) }
  it { should respond_to(:abreviation) }
  # it { should_not respond_to(:search_name) }
  it { should respond_to(:measurement_aliases) }

  describe "names should be unique and not case sensetive" do
    before do
      @dup_unit = @measuring_unit.dup()
      @dup_unit.name = @dup_unit.name.upcase()
      @dup_unit.save()
    end

    it { should_not be_valid }
  end

  describe "abreviation should default to name" do
    test_unit = MeasuringUnit.new(name: "Test Tablespoon")
    test_unit.name.should == test_unit.abreviation
  end

  describe "abreviation should be able to be different" do
    test_unit = MeasuringUnit.new(name: "Test Tablespoon", abreviation: "test Tbsp.")
    test_unit.name.should_not == test_unit.abreviation
  end

  describe "abreviation should be able to be an empty string" do
    test_unit = MeasuringUnit.new(name: "Fred", abreviation: "")
    test_unit.name.should_not == test_unit.abreviation
  end

  describe "should create default aliases on save" do
    it do
      @measuring_unit.save!()
      @measuring_unit.measurement_aliases.length.should == 2
    end
  end

  describe "should create an alias for the abreviation on save" do
    it do
      @measuring_unit.abreviation = Faker::Lorem.sentence()
      @measuring_unit.save!()
      @measuring_unit.measurement_aliases.length.should == 3
    end
  end

  describe "Should be able to search for aliases" do
    before do
      @measuring_unit.save!()
      @measuring_unit.add_alias("Tc").save!()
      @measuring_unit.add_alias("tc.").save!()
      @measuring_unit.add_alias("Test Cups").save!()
    end

    it { should be_valid }

    it do
      found_unit = MeasuringUnit.find_by_alias("tC")
      should == found_unit
    end
  end

  describe "Should not find an unused alias" do
    before do
      @measuring_unit.save!()
      @measuring_unit.add_alias("Tc").save!()
      @measuring_unit.add_alias("tc.").save!()
      @measuring_unit.add_alias("Test Cups").save!()
    end

    it { should be_valid }

    it do
      found_unit = MeasuringUnit.find_by_alias(Faker::Lorem.sentence())
      found_unit.should == nil
    end
  end
end