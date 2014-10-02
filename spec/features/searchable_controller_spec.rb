require "spec_helper"

[
    :search_alias,
    :container,
    :ingredient,
    :ingredient_category,
    :keyword,
    :measuring_unit,
    :prep_order,
    :recipe,
    :recipe_type
].each do |class_symbol|
  describe "#{class_symbol.to_s.classify.pluralize}Controller".constantize, :type => :feature do
    describe "is a searchable scrollable controller", type: :feature do
      it_behaves_like "a searchable scrollable list controller"
    end
  end
end