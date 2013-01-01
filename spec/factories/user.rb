require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    email Faker::Internet.email

    generated_password = Faker::Lorem.sentence
    password generated_password
  end
end