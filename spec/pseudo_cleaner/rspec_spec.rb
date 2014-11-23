require "rails_helper"

RSpec.describe "rspec options for Pseudo-Cleaner" do
  around(:each) do |example|
    orig_diagnostics                                                 = PseudoCleaner::Configuration.current_instance.output_diagnostics
    PseudoCleaner::Configuration.current_instance.output_diagnostics = true

    @rspec_test_example = example

    example.run
    PseudoCleaner::Configuration.current_instance.output_diagnostics = orig_diagnostics
  end

  describe ":none" do
    around(:each) do |example|
      PseudoCleaner::MasterCleaner.clean(:test, :pseudo_delete) do
        total_count = MeasuringUnit.count
        max_id      = MeasuringUnit.maximum(:id)
        alias_id    = SearchAlias.maximum(:id)

        example.run

        expect(SearchAlias.maximum(:id)).to be > alias_id
        expect(MeasuringUnit.count).to eq(total_count + 1)
        MeasuringUnit.destroy_all(["id > :id", id: max_id])
      end
    end

    it "does nothing", strategy: :none do
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":transaction" do
    before(:context) do
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do
      expect(SearchAlias.maximum(:id)).to eq @alias_id
      expect(MeasuringUnit.count).to eq(@total_count)
    end

    it "uses the strategy :transaction", strategy: :transaction do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:transaction)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe "defaults" do
    before(:context) do
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do
      expect(SearchAlias.maximum(:id)).to eq @alias_id
      expect(MeasuringUnit.count).to eq(@total_count)
    end

    it "defaults to :transaction" do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:transaction)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":truncation" do
    before(:context) do
      @orig_id     = PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner).__id__
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do
      expect(PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner).__id__).not_to eq(@orig_id)
      expect(MeasuringUnit.first.id).to eq 1
      expect(MeasuringUnit.count).to eq(@total_count)
      expect(SearchAlias.maximum(:id)).to eq @alias_id
    end

    it "truncates the database after the example runs", strategy: :truncation do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:truncation)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":deletion" do
    before(:context) do
      @orig_id     = PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner).__id__
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do
      expect(PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner).__id__).not_to eq(@orig_id)
      expect(MeasuringUnit.first.id).not_to eq 1
      expect(MeasuringUnit.count).to eq(@total_count)
      expect(SearchAlias.maximum(:id)).to eq @alias_id
    end

    it "truncates the database after the example runs", strategy: :deletion do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:deletion)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":pseudo_delete" do
    before(:context) do |example|
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do |example|
      expect(MeasuringUnit.count).to eq(@total_count)
      expect(SearchAlias.maximum(:id)).to eq @alias_id
    end

    it "truncates the database after the example runs", strategy: :pseudo_delete do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:pseudo_delete)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":js" do
    before(:context) do |example|
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do |example|
      expect(SearchAlias.maximum(:id)).to eq @alias_id
      expect(MeasuringUnit.count).to eq(@total_count)
    end

    it "truncates the database after the example runs", :js do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:pseudo_delete)
      FactoryGirl.create(:measuring_unit)
    end
  end

  describe ":js, strategy: transaction" do
    before(:context) do |example|
      @total_count = MeasuringUnit.count
      @alias_id    = SearchAlias.maximum(:id)
    end

    after(:context) do |example|
      expect(MeasuringUnit.count).to eq(@total_count)
      expect(SearchAlias.maximum(:id)).to eq @alias_id
    end

    it "truncates the database after the example runs", :js, strategy: :transaction do |example|
      expect(example.instance_variable_get(:@pseudo_cleaner_data)[:test_strategy]).to eq(:pseudo_delete)
      FactoryGirl.create(:measuring_unit)
    end
  end
end