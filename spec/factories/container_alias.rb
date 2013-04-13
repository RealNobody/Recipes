require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :container_alias do
    container_id do
      container = FactoryGirl.create(:container)
      container.id
    end

    self.alias { Faker::Lorem.sentence }
  end
end