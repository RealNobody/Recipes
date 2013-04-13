require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :container do
    name { Faker::Name.name }
  end
end