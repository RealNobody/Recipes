require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :measuring_unit do
    name { FactoryHelper.create_aliased_field(MeasuringUnit) { Faker::Name.name } }
    abbreviation { FactoryHelper.create_aliased_field(MeasuringUnit) { Faker::Name.name } }
  end
end