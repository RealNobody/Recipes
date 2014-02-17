require "spec_helper"

describe SearchAliasesController do
  let(:test_user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in test_user
  end

  describe "#destroy" do
    let(:delete_item) do
      do_not_delete_class = SearchAlias.aliased_tables.find do |alias_class|
        !alias_class.allow_delete_defaults
      end

      delete_alias = FactoryGirl.create(:search_alias, aliased_type: do_not_delete_class.name)
      SearchAlias.where(alias:  delete_alias.aliased[do_not_delete_class.initialize_field]).first
    end

    it "should not delete the item if it cannot" do
      deleted_id = delete_item.id

      delete :destroy, id: deleted_id

      expect(response).to be_success
      expect(assigns(described_class.controller_name.singularize)).to eq(delete_item)
      expect(response).to render_template("index")
      expect(SearchAlias.where(id: deleted_id).first).to be
      expect(flash[:error]).to_not be_empty
    end
  end
end