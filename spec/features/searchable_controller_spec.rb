require "spec_helper"

#[:ingredient].
[:container,
 :ingredient,
 :ingredient_category,
 :keyword,
 :measuring_unit,
 :prep_order,
 :recipe,
 :recipe_type].
    each do |class_symbol|
  describe "#{class_symbol.to_s.classify.pluralize}Controller".constantize do
    describe "is a scrollable controller", type: :feature do
      it_behaves_like "a scrollable list controller"
    end

    describe "is a searchable scrollable controller", type: :feature do
      it_behaves_like "a searchable scrollable list controller"
    end
  end
end