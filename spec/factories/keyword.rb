require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :keyword do
    name { FactoryHelper.create_aliased_field(Keyword) { Faker::Name.name } }
  end
end