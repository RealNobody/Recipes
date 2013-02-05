# == Schema Information
#
# Table name: measuring_units
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  abbreviation :string(255)
#  search_name :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe MeasuringUnit do
  before do
    @measuring_unit = FactoryGirl.build(:measuring_unit)
  end

  subject { @measuring_unit }

  it { should respond_to(:name) }
  it { should respond_to(:abbreviation) }
  # it { should_not respond_to(:search_name) }
  it { should respond_to(:measurement_aliases) }
  it { should respond_to(:can_delete) }

  describe "names should be unique and not case sensetive" do
    before do
      @dup_unit      = @measuring_unit.dup()
      @dup_unit.name = @dup_unit.name.upcase()
      @dup_unit.save()
    end

    it { should_not be_valid }
  end

  describe "abbreviation should default to name" do
    test_unit = MeasuringUnit.new(name: "Test Tablespoon")
    test_unit.name.should == test_unit.abbreviation
  end

  describe "abbreviation should be able to be different" do
    test_unit = MeasuringUnit.new(name: "Test Tablespoon", abbreviation: "test Tbsp.")
    test_unit.name.should_not == test_unit.abbreviation
  end

  describe "abbreviation should be able to be an empty string" do
    test_unit = MeasuringUnit.new(name: "Fred", abbreviation: "")
    test_unit.name.should_not == test_unit.abbreviation
  end

  describe "should create default aliases on save" do
    it do
      # FactoryGirl may or may not create an abbreviation...
      @measuring_unit.abbreviation = Faker::Name.name
      @measuring_unit.save!()

      @measuring_unit.measurement_aliases.length.should == 3
    end
  end

  describe "should create an alias for the abbreviation on save" do
    it do
      @measuring_unit.abbreviation = Faker::Lorem.sentence()
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

  describe "Should be deletable" do
    it do
      @measuring_unit.save!()
      @measuring_unit.can_delete.should equal true
      unit_destroyed = @measuring_unit.destroy()
      unit_destroyed.should equal @measuring_unit
    end
  end

  describe "seeds should not be deletable" do
    base_unit      = MeasuringUnit.where(search_name: "cup").first()
    unit_destroyed = base_unit.destroy()
    unit_destroyed.should == false
  end

  describe "has abbreviation" do
    it "should nil the abbreviation if set to false" do
      @measuring_unit.has_abbreviation = false
      @measuring_unit[:abbreviation].should be_blank
    end

    it "should not alter the abbreviation if set to true" do
      orig_abbreviation                = @measuring_unit[:abbreviation]
      @measuring_unit.has_abbreviation = true
      @measuring_unit[:abbreviation].should eq(orig_abbreviation)
    end
  end

  describe "find_or_initialize" do
    it "should create a new record if it doesn't exist" do
      new_unit = MeasuringUnit.find_or_initialize(Faker::Name.name)
      new_unit.id.should be_blank
    end

    it "should find an existing record if it does exist" do
      @measuring_unit.save()
      new_unit = MeasuringUnit.find_or_initialize(@measuring_unit.name)
      new_unit.id.should_not be_blank
    end
  end
end