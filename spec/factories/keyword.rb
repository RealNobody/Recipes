require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :keyword do
    name { Faker::Name.name }
  end
end