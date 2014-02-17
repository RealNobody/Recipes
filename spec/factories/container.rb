require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :container do
    name { FactoryHelper.create_aliased_field(Container) { Faker::Name.name } }
  end
end