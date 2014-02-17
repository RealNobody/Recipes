require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :search_alias do
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

    self.alias { FactoryHelper.create_aliased_field(aliased_type.constantize) { Faker::Lorem.sentence } }
  end
end