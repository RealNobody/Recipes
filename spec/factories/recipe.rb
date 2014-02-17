require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :recipe do
    name { FactoryHelper.create_aliased_field(Recipe) { Faker::Name.name } }
    recipe_type_id do
      recipe_type = FactoryGirl.create(:recipe_type)
      recipe_type.id
    end
    prep_order_id do
      prep_order = FactoryGirl.create(:prep_order)
      prep_order.id
    end
    cooking_instructions { Faker::Lorem.paragraphs.join("\n\n") }
    label_instructions { Faker::Lorem.sentence }
    meals { rand(20) }
    prep_instructions { Faker::Lorem.paragraphs.join("\n\n") }
    servings { rand(20) }
  end
end