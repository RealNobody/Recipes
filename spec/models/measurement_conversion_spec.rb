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

  it "should require a smaller id" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: nil,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 1.0)
    test_unit.should_not be_valid
  end

  it "should require a larger id" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  nil, multiplier: 1.0)
    test_unit.should_not be_valid
  end

  it "should require a valid smaller id" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: -1,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 1.0)
    test_unit.should_not be_valid
  end

  it "should require a valid larger id" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  -1, multiplier: 1.0)
    test_unit.should_not be_valid
  end

  it { should respond_to(:smaller_measuring_unit_id) }
  it { should respond_to(:larger_measuring_unit_id) }
  it { should respond_to(:multiplier) }
  it { should respond_to(:list_name) }

  it "should have the right list name" do
    test_unit = MeasurementConversion.new(smaller_measuring_unit_id: @smaller_measuring_unit.id,
                                          larger_measuring_unit_id:  @larger_measuring_unit.id, multiplier: 0.5)

    test_unit.list_name.should eq(I18n.t("activerecord.measurement_conversion.list_name",
                                         smaller_unit: @smaller_measuring_unit.abbreviation,
                                         larger_unit:  @larger_measuring_unit.abbreviation))
  end

  describe "#search_alias" do
    it "should not search yet" do
      results = MeasurementConversion.search_alias("z", offset: 0, limit: 2)
      expect(results[0]).to eq(MeasurementConversion.count)
      expect(results[1].count).to eq(2)
    end
  end
end