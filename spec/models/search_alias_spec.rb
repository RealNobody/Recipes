require 'spec_helper'

RSpec.describe SearchAlias, :type => :model do
  let(:search_alias) { FactoryGirl.build(:search_alias) }

  subject { search_alias }

  it { is_expected.to respond_to :aliased_id }
  it { is_expected.to respond_to :aliased_type }
  it { is_expected.to respond_to :aliased }
  it { is_expected.to respond_to :list_name }

  it "should have an #initialize_field" do
    expect(SearchAlias.initialize_field).to eq(:alias)
  end

  describe "basic validation" do
    it { is_expected.to be_valid }

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

    it "should not allow an alias > 255 characters" do
      search_alias.alias = "x" * 256
      expect(search_alias).to_not be_valid
    end

    it "should require an aliased" do
      search_alias.aliased_id = nil
      expect(search_alias).not_to be_valid
    end

    it "should require a valid aliased" do
      search_alias.aliased_id = -1
      expect(search_alias).not_to be_valid
    end

    it "should be unique case insensitive" do
      alias_test = search_alias.clone
      alias_test.save!

      search_alias.alias = search_alias.alias.upcase

      expect(search_alias).not_to be_valid
    end
  end

  it "should return a default list_name for an empty alias" do
    expect(SearchAlias.new().list_name).to eq(I18n.t("activerecord.search_alias.new_label"))
  end

  it "should have a list name" do
    expect(search_alias.list_name).to eq("%{alias} (%{name})" % {
        alias: search_alias.alias,
        name:  search_alias.aliased.name })
  end

  it "should sort by aliased_type index_sort" do
    expect(SearchAlias.respond_to?("#{search_alias.aliased.class.name.underscore}_index_sort")).to be_truthy
    expect(SearchAlias.send("#{search_alias.aliased.class.name.underscore}_index_sort").last).to be
  end
end