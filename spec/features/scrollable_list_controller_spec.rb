require "rails_helper"

[
    :search_alias,
    :container,
    :ingredient,
    :ingredient_category,
    :keyword,
    :measuring_unit,
    :prep_order,
    :recipe,
    :recipe_type,
    :measurement_conversion
].each do |class_symbol|
  RSpec.describe "#{class_symbol.to_s.classify.pluralize}Controller".constantize, :type => :feature do
    describe "is a scrollable controller", type: :feature do
      it_behaves_like "a scrollable list controller"
    end
  end
end