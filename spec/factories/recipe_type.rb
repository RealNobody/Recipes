require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :recipe_type do
    name { FactoryHelper.create_aliased_field(RecipeType) { Faker::Name.name } }
  end
end