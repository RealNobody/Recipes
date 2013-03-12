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
  #it { should respond_to(:larger_measurement_conversions) }
  it { should respond_to(:ingredients) }

  describe "names should be unique and not case sensitive" do
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

  describe "default aliases" do
    it "should create 3 aliases with an abbreviation" do
      abrev_unit = FactoryGirl.create(:measuring_unit, name: Faker::Name.name.singularize, abbreviation: Faker::Name.name)

      abrev_unit.measurement_aliases.length.should == 3
    end

    it "should create 2 aliases with an abbreviation" do
      abrev_unit = FactoryGirl.create(:measuring_unit, name: Faker::Name.name.singularize, abbreviation: nil)

      abrev_unit.measurement_aliases.length.should == 2
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

    it "should not allow an alias to be added for two measuring units" do
      alias_text = Faker::Lorem.sentence
      alt_measuring_unit = FactoryGirl.create(:measuring_unit)
      alt_measuring_unit.add_alias(alias_text).save!

      @measuring_unit.add_alias(alias_text).should eq(nil)
    end

    it "should not allow a measuring unit to be added by alias name" do
      new_unit = FactoryGirl.build(:measuring_unit, name: "TC.")
      new_unit.should_not be_valid
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

  describe "conversions" do
    before(:each) do
      @smaller_unit   = FactoryGirl.create(:measuring_unit)
      @larger_unit    = FactoryGirl.create(:measuring_unit)
      @middle_unit    = FactoryGirl.create(:measuring_unit)
      @unrelated_unit = FactoryGirl.create(:measuring_unit)
    end

    describe "can convert" do
      before(:each) do
        @smaller_unit.add_conversion(@middle_unit, 2)
        @middle_unit.add_conversion(@larger_unit, 3)
      end

      it "should know immediate up conversions" do
        @smaller_unit.can_convert_to(@middle_unit).should eq(true)
      end

      it "should know immediate down conversions" do
        @larger_unit.can_convert_to(@middle_unit).should eq(true)
      end

      it "should know skip up conversions" do
        @smaller_unit.can_convert_to(@larger_unit).should eq(true)
      end

      it "should know skip down conversions" do
        @larger_unit.can_convert_to(@smaller_unit).should eq(true)
      end

      it "should know unsupported conversions" do
        @smaller_unit.can_convert_to(@unrelated_unit).should eq(false)
      end
    end

    it "should allow skip conversions to larger units put in backwards" do
      @smaller_unit.add_conversion(@larger_unit, 6)
      @middle_unit.add_conversion(@larger_unit, 3)

      @smaller_unit.convert_to(@middle_unit).should eq(2)
    end

    it "should allow skip conversions to larger units put in odd" do
      @smaller_unit.add_conversion(@larger_unit, 6)
      @smaller_unit.add_conversion(@middle_unit, 2)

      @middle_unit.convert_to(@larger_unit).should eq(3)
    end

    it "should allow conversion to larger units" do
      @smaller_unit.add_conversion(@larger_unit, 2)

      @smaller_unit.convert_to(@larger_unit).should eq(2)
    end

    it "should allow conversion to smaller units" do
      @larger_unit.add_conversion(@smaller_unit, 2)

      @smaller_unit.convert_to(@larger_unit).should eq(0.5)
    end

    describe "intermediate conversions" do
      it "automatically add intermediate conversions up" do
        @smaller_unit.add_conversion(@middle_unit, 2)
        @middle_unit.add_conversion(@larger_unit, 3)

        @smaller_unit.convert_to(@larger_unit).should eq(2 * 3)
      end

      it "automatically add intermediate conversions down" do
        @middle_unit.add_conversion(@larger_unit, 3)
        @smaller_unit.add_conversion(@middle_unit, 2)

        @larger_unit.convert_to(@smaller_unit).should eq(1.0 / (2 * 3))
      end

      it "should return 1 for unsupported conversion" do
        @smaller_unit.add_conversion(@larger_unit, 2)

        @smaller_unit.convert_to(@middle_unit).should eq(1)
      end

      it "should test seeding" do
        test_unit = MeasuringUnit.find_or_initialize("Cup")
        test_unit.tap do |unit|
          unit              = MeasuringUnit.find(unit.id, readonly: false)
          unit.abbreviation = "C."
          unit.can_delete   = false
          unit.save!()

          unit.add_alias("c").save!()
        end
      end
    end
  end
end