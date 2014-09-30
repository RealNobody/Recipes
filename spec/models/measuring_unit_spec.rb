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

  let(:subject) { @measuring_unit }

  describe "is an aliased table" do
    it_behaves_like "an aliased table"
  end

  it { should respond_to(:name) }
  it { should respond_to(:abbreviation) }
  it { should_not respond_to(:search_name) }
  it { should respond_to(:search_aliases) }
  it { should respond_to(:can_delete) }
  it { should respond_to(:larger_measurement_conversions) }
  it { should respond_to(:smaller_measurement_conversions) }
  it { should respond_to(:ingredients) }

  describe "names should be unique and not case sensitive" do
    before do
      @dup_unit      = @measuring_unit.dup()
      @dup_unit.name = @dup_unit.name.upcase()
      @dup_unit.save()
    end

    it { should_not be_valid }
  end

  describe "abbreviation" do
    it "should default to name" do
      test_unit = MeasuringUnit.new(name: "Test Tablespoon")
      test_unit.name.should == test_unit.abbreviation
    end

    it "should be able to be different" do
      test_unit = MeasuringUnit.new(name: "Test Tablespoon", abbreviation: "test Tbsp.")
      test_unit.name.should_not == test_unit.abbreviation
    end

    it "should be able to be an empty string" do
      test_unit = MeasuringUnit.new(name: "Fred", abbreviation: "")
      test_unit.name.should_not == test_unit.abbreviation
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

  it "seeds should not be deletable" do
    base_unit      = MeasuringUnit.find_or_initialize("cup")
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
        expect(@smaller_unit.can_convert_to(@middle_unit)).to be_truthy
      end

      it "should know immediate down conversions" do
        expect(@larger_unit.can_convert_to(@middle_unit)).to be_truthy
      end

      it "should know skip up conversions" do
        expect(@smaller_unit.can_convert_to(@larger_unit)).to be_truthy
      end

      it "should know skip down conversions" do
        expect(@larger_unit.can_convert_to(@smaller_unit)).to be_truthy
      end

      it "should know unsupported conversions" do
        expect(@smaller_unit.can_convert_to(@unrelated_unit)).to be_falsey
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
          unit              = MeasuringUnit.find(unit.id)
          unit.abbreviation = "C."
          unit.can_delete   = false
          unit.save!()

          unit.add_alias("c").save!()
        end
      end
    end
  end
end