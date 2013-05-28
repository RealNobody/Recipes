require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :keyword_alias do
    keyword_id do
      keyword = FactoryGirl.create(:keyword)
      keyword.id
    end

    self.alias { Faker::Lorem.sentence }
  end
end