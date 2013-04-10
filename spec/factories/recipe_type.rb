require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :recipe_type do
    name { Faker::Name.name }
  end
end