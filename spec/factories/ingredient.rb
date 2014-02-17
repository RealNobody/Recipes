require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :ingredient do
    measuring_unit_id do
      measuring_unit = FactoryGirl.create(:measuring_unit)
      measuring_unit.id
    end

    ingredient_category_id do
      ingredient_category = FactoryGirl.create(:ingredient_category)
      ingredient_category.id
    end

    prep_instructions { Faker::Lorem.paragraphs.join("\n\n") }
    day_before_prep_instructions { Faker::Lorem.paragraphs.join("\n\n") }
    name { FactoryHelper.create_aliased_field(Ingredient) { Faker::Name.name } }
  end
end