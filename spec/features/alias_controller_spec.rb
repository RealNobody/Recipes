require "spec_helper"

[:container_aliases].each do |class_symbol|
  describe "#{class_symbol.to_s.classify.pluralize}Controller".constantize do
    describe "is a scrollable controller", type: :feature do
      it_behaves_like "a scrollable list controller"
    end
  end
end