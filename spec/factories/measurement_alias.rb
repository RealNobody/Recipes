require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :measurement_alias do
    measuring_unit_id do
      measuring_unit = FactoryGirl.create(:ingredient)
      measuring_unit.id
    end

    self.alias { Faker::Lorem.sentence }
  end
end