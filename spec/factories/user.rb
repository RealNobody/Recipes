require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }

    password { Faker::Lorem.sentence }
    password_confirmation { "#{password}" }
  end
end