# == Schema Information
#
# Table name: measurement_aliases
#
#  id                :integer(4)      not null, primary key
#  alias             :string(255)
#  measuring_unit_id :integer(4)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'spec_helper'
require 'faker'

describe MeasurementAlias do
  let(:measuring_unit) { FactoryGirl.create(:measuring_unit) }

  before do
    @measurement_alias = measuring_unit.add_alias(Faker::Lorem.sentence)
  end

  subject { @measurement_alias }

  it { should respond_to(:alias) }
  it { should respond_to(:measuring_unit_id) }
  it { should respond_to(:measuring_unit) }
  it { should respond_to(:list_name) }

  it { should be_valid }

  it "should not allow a nil alias" do
    @measurement_alias.alias = nil
    @measurement_alias.should_not be_valid
  end

  # This fails because of the seeded value, so it is tested that way.
  #it "should allow a blank alias" do
  #  @measurement_alias.alias = ""
  #  @measurement_alias.should be_valid
  #end

  it "should require a measuring unit" do
    @measurement_alias.measuring_unit_id = nil
    @measurement_alias.should_not be_valid
  end

  it "should require a valid measuring unit" do
    @measurement_alias.measuring_unit_id = -1
    @measurement_alias.should_not be_valid
  end

  describe "should be unique case insensitive" do
    before do
      dup_measuring_unit = FactoryGirl.create(:measuring_unit)
      dup_alias          = dup_measuring_unit.add_alias(@measurement_alias.alias.upcase())
      dup_alias.save!()
    end

    it { should_not be_valid }
  end

  describe "handle deletions" do
    before do
      @measurement_alias.save!()
    end

    it "should be deleted when the parent is deleted" do
      measuring_unit.destroy()
      found_alias = MeasurementAlias.where(id: @measurement_alias.id)
      found_alias.length.should(equal(0))
    end

    it "should not allow default aliases to be deleted" do
      delete_alias = MeasurementAlias.where(alias: measuring_unit.name.downcase()).first()
      delete_id    = delete_alias.id
      delete_alias.destroy()
      found_alias = MeasurementAlias.where(id: delete_id)
      found_alias.length.should_not equal 0
    end

    it "should allow non-default aliases to be deleted" do
      delete_id = @measurement_alias.id
      @measurement_alias.destroy()
      found_alias = MeasurementAlias.where(id: delete_id)
      found_alias.length.should equal 0
    end
  end

  it "should have a list name" do
    @measurement_alias.list_name.should eq(I18n.t("activerecord.measurement_alias.list_name", alias: @measurement_alias.alias, measuring_unit: measuring_unit.name))
  end

  it "should allow blank aliases" do
    find_alias = MeasuringUnit.find_by_alias("")

    unless (find_alias)
      find_alias                = MeasurementAlias.new(alias: "")
      find_alias.measuring_unit = MeasuringUnit.first()
    end

    find_alias.should be_valid
  end
end