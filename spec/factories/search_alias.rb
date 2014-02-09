require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :search_alias do
    self.alias { Faker::Lorem.sentence }
    aliased_type { [
        :container,
        :ingredient,
        :ingredient_category,
        :keyword,
        :measuring_unit,
        :prep_order,
        :recipe,
        :recipe_type
    ].sample().to_s.classify
    }

    aliased_id { FactoryGirl.create(aliased_type.underscore.to_sym).id }
  end
end