require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :measurement_conversion do
    smaller_measuring_unit_id { FactoryGirl.create(:measuring_unit).id }
    larger_measuring_unit_id { FactoryGirl.create(:measuring_unit).id }

    multiplier do
      value_1 = 1 + rand(499)
      value_2 = 1 + rand(499)

      if (value_1 < value_2)
        val_3 = value_1
        value_1 = value_2
        value_2 = val_3
      end

      (value_1 * 1.0) / (value_2 * 1.0)
    end
  end
end