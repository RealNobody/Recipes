require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :prep_order do
    name { Faker::Name.name }
    order { rand(1000...2000) }
  end
end