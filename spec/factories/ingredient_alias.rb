require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :ingredient_alias do
    ingredient_id do
      ingredient = FactoryGirl.create(:ingredient)
      ingredient.id
    end

    self.alias { Faker::Lorem.sentence }
  end
end