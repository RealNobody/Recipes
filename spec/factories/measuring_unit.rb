require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :measuring_unit do
    name Faker::Name.name
    if ([0, 1].sample == 0)
      abreviation Faker::Name.name
    end
  end
end