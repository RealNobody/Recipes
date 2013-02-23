require 'spec_helper'

describe MeasurementConversion do
  before(:each) do
    @smaller_measuring_unit = FactoryGirl.create(:measuring_unit)
    @larger_measuring_unit  = FactoryGirl.create(:measuring_unit)
  end

  it "should not allow multipliers < 1" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 0.5)
    test_unit.should_not be_valid
  end

  it "should allow multipliers > 1" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 1.0001)
    test_unit.should be_valid
  end

  it "should allow multipliers == 1" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 1.0)
    test_unit.should be_valid
  end

  it "should not allow duplicates with inverted ids" do
    real_conversion = MeasurementConversion.create(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                                   larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 1.0)
    test_unit       = MeasurementConversion.new(smaller_measuring_unit_id: @larger_measuring_unit.id,
                                                larger_measuring_unit_id:  @smaller_measuring_unit.id, multiplier: 1.0)

    test_unit.should_not be_valid
  end

  it { should respond_to(:smaller_measuring_unit_id) }
  it { should respond_to(:larger_measuring_unit_id) }
  it { should respond_to(:multiplier) }
end