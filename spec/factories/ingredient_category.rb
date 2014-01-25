require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :ingredient_category do
    name { Faker::Name.name }
    order { IngredientCategory.index_sort.last().order + 1 }
  end
end