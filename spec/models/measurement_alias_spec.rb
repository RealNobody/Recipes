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

  it { should be_valid }

  describe "should be unique case insensetive" do
    before do
      dup_measuring_unit = FactoryGirl.create(:measuring_unit)
      dup_alias = dup_measuring_unit.add_alias(@measurement_alias.alias.upcase())
      dup_alias.save!()
    end

    it { should_not be_valid }
  end

  describe "should be deleted when the parent is deleted" do
    before do
      @measurement_alias.save!()
    end

    it do
      measuring_unit.destroy()
      found_alias = MeasurementAlias.where(id: @measurement_alias.id)
      found_alias.length.should(equal(0))
    end
  end
end