require 'spec_helper'

describe SearchAlias do
  let(:search_alias) { FactoryGirl.build(:search_alias) }

  subject { search_alias }

  it { should respond_to :aliased_id }
  it { should respond_to :aliased_type }
  it { should respond_to :aliased }
  it { should respond_to :list_name }
  [
      :container,
      :ingredient,
      :ingredient_category,
      :keyword,
      :measuring_unit,
      :prep_order,
      :recipe,
      :recipe_type
  ].each do |aliased_type|
    it "should index by #{aliased_type}_index_sort" do
      SearchAlias.should respond_to "#{aliased_type}_index_sort"
    end
  end

  it "should have an #initialize_field" do
    expect(SearchAlias.initialize_field).to eq(:alias)
  end

  describe "basic validation" do
    it { should be_valid }

    it "should not allow a nil alias" do
      search_alias.alias = nil
      expect(search_alias).to_not be_valid
    end

    it "should not allow a blank alias" do
      search_alias.alias = ""
      if (search_alias.aliased.class.allow_blank_aliases)
        blank_aliased_item = search_alias.aliased.class.find_by_alias("")
        unless blank_aliased_item
          expect(search_alias).to be_valid
        end
      else
        expect(search_alias).to_not be_valid
      end
    end

    it "should require an aliased" do
      search_alias.aliased_id = nil
      search_alias.should_not be_valid
    end

    it "should require a valid aliased" do
      search_alias.aliased_id = -1
      search_alias.should_not be_valid
    end

    it "should be unique case insensitive" do
      alias_test = search_alias.clone
      alias_test.save!

      search_alias.alias = search_alias.alias.upcase

      search_alias.should_not be_valid
    end
  end

  it "should have a list name" do
    search_alias.list_name.should eq("%{alias} (%{name})" % {
        alias: search_alias.alias,
        name:  search_alias.aliased.name })
  end

  it "should sort by aliased_type index_sort" do
    expect(SearchAlias.respond_to?("#{search_alias.aliased.class.name.underscore}_index_sort")).to be_true
    expect(SearchAlias.send("#{search_alias.aliased.class.name.underscore}_index_sort").last).to be
  end

  describe "does not allow default alias deletions" do
    let(:alias_type) do
      [
          :container,
          :ingredient,
          :ingredient_category,
          :keyword,
          :measuring_unit,
          :prep_order,
          :recipe,
          :recipe_type
      ].select { |class_symbol| !class_symbol.to_s.classify.constantize.allow_delete_defaults }.sample().to_s.classify
    end
    let(:do_not_delete_alias) { FactoryGirl.build(:search_alias, aliased_type: alias_type) }

    before do
      do_not_delete_alias.save!()
    end

    it "should be deleted when the parent is deleted" do
      do_not_delete_alias.aliased.destroy()
      found_alias = SearchAlias.where(id: do_not_delete_alias.id)
      expect(found_alias.length).to be > 0
    end

    it "should not allow default aliases to be deleted" do
      delete_alias = SearchAlias.where(alias: do_not_delete_alias.aliased.
                                                  send(do_not_delete_alias.aliased.class.initialize_field).downcase()).
          first()
      delete_id    = delete_alias.id
      delete_alias.destroy()
      found_alias = SearchAlias.where(id: delete_id)
      expect(found_alias.length).to be > 0
    end

    it "should allow non-default aliases to be deleted" do
      delete_id = do_not_delete_alias.id
      do_not_delete_alias.destroy()
      found_alias = SearchAlias.where(id: delete_id)
      expect(found_alias.length).to be <= 0
    end
  end

  describe "allows default alias deletions" do
    let(:alias_type) do
      [
          :container,
          :ingredient,
          :ingredient_category,
          :keyword,
          :measuring_unit,
          :prep_order,
          :recipe,
          :recipe_type
      ].select { |class_symbol| class_symbol.to_s.classify.constantize.allow_delete_defaults }.sample().to_s.classify
    end
    let(:allow_delete_alias) { FactoryGirl.build(:search_alias, aliased_type: alias_type) }

    before do
      allow_delete_alias.save!()
    end

    it "should be deleted when the parent is deleted" do
      allow_delete_alias.aliased.destroy()
      found_alias = SearchAlias.where(id: allow_delete_alias.id)
      expect(found_alias.length).to be > 0
    end

    it "should allow default aliases to be deleted" do
      delete_alias = SearchAlias.where(alias: allow_delete_alias.aliased.
                                                  send(allow_delete_alias.aliased.class.initialize_field).downcase()).
          first()
      delete_id    = delete_alias.id
      delete_alias.destroy()
      found_alias = SearchAlias.where(id: delete_id)
      expect(found_alias.length).to be <= 0
    end

    it "should allow non-default aliases to be deleted" do
      delete_id = allow_delete_alias.id
      allow_delete_alias.destroy()
      found_alias = SearchAlias.where(id: delete_id)
      expect(found_alias.length).to be <= 0
    end
  end
end