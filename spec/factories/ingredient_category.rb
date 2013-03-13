require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :ingredient_category do
    name { Faker::Name.name }
    order { IngredientCategory.all.last().order + 1 }
  end
end