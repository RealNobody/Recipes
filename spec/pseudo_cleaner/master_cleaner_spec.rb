require "rails_helper"

RSpec.describe PseudoCleaner::MasterCleaner do
  let(:example_object) { Object.new }
  let(:sample_string) { Faker::Lorem.sentence }
  let(:cleaner_double) { instance_double("PseudoCleaner::MasterCleaner") }

  around(:each) do |example|
    orig_states      = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)
    orig_diagnostics = PseudoCleaner::Configuration.current_instance.output_diagnostics

    PseudoCleaner::TableCleaner.class_variable_set(:@@initial_states, orig_states.clone)
    PseudoCleaner::Configuration.current_instance.output_diagnostics = true

    example.run

    PseudoCleaner::Configuration.current_instance.output_diagnostics = orig_diagnostics
    PseudoCleaner::TableCleaner.class_variable_set(:@@initial_states, orig_states)
  end

  before(:each) do
    FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/rspec_fixture"))
    FileUtils.mkdir_p(File.join(Rails.root, "/db/cleaners"))
  end

  after(:each) do
    FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/rspec_fixture"))

    if Dir[File.join(Rails.root, "/db/cleaners/*")].blank?
      FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/"))
    end

    if Object.const_defined?("MeasuringUnitCleaner", false)
      Object.send(:remove_const, "MeasuringUnitCleaner")
    end
  end

  describe "#start_suite" do
    it "creates and starts a new MasterCleaner" do
      new_cleaner = PseudoCleaner::MasterCleaner.new(:suite)

      expect(PseudoCleaner::MasterCleaner).to receive(:new).with(:suite).and_return(new_cleaner)
      expect(new_cleaner).to receive(:start).with(:pseudo_delete)
      expect(PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner)).
          to receive(:reset_suite).and_return(nil)
      started_cleaner = PseudoCleaner::MasterCleaner.start_suite

      expect(started_cleaner).to eq new_cleaner
      expect(PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner)).to eq new_cleaner
    end
  end

  describe "#end_suite" do
    it "calls @@suite_cleaner.end" do
      started_cleaner = PseudoCleaner::MasterCleaner.start_suite
      expect(started_cleaner).to receive(:end).with({ test_strategy: :pseudo_delete })
      PseudoCleaner::MasterCleaner.end_suite
    end
  end

  describe "#start_example" do # 2413 3124 4321 1243 4231 1342 1324 3124 # 1432
    it "doesn't call much of anything when :none", strategy: :none do
      expect(DatabaseCleaner).not_to receive(:start)
      expect(PseudoCleaner::MasterCleaner).not_to receive(:start_test)

      PseudoCleaner::MasterCleaner.start_example(example_object, :none)

      expect(example_object.instance_variable_get(:@pseudo_cleaner_data)).to eq({ test_strategy: :none })

      RSpec::Mocks.space.proxy_for(DatabaseCleaner).verify
      RSpec::Mocks.space.proxy_for(DatabaseCleaner).reset
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).reset
    end

    it "doesn't allow invalid strategies", strategy: :none do
      expect { PseudoCleaner::MasterCleaner.start_example(example_object, Faker::Lorem.word.to_sym) }.to raise_exception
    end

    it "doesn't call DatabaseCleaner.start for :pseudo_delete", strategy: :none do
      strategy = [:pseudo_delete].sample

      expect(DatabaseCleaner).not_to receive(:start)
      expect(PseudoCleaner::MasterCleaner).to receive(:start_test).with(strategy).and_return(sample_string)

      PseudoCleaner::MasterCleaner.start_example(example_object, strategy)

      expect(example_object.instance_variable_get(:@pseudo_cleaner_data)).
          to eq({ test_strategy: strategy, pseudo_state: sample_string })

      RSpec::Mocks.space.proxy_for(DatabaseCleaner).verify
      RSpec::Mocks.space.proxy_for(DatabaseCleaner).reset
    end

    it "does call DatabaseCleaner.start for :transaction, :trunction or :deletion", strategy: :none do
      strategy = [:transaction, :truncation, :deletion].sample

      expect(DatabaseCleaner).to receive(:start).and_return(nil)
      expect(PseudoCleaner::MasterCleaner).to receive(:start_test).with(strategy).and_return(sample_string)

      PseudoCleaner::MasterCleaner.start_example(example_object, strategy)

      expect(example_object.instance_variable_get(:@pseudo_cleaner_data)).
          to eq({ test_strategy: strategy, pseudo_state: sample_string })
    end
  end

  describe "#end_example" do
    let(:example_object) { Object.new }

    it "does nothing if the strategy is :none" do
      example_object.instance_variable_set(:@pseudo_cleaner_data, { test_strategy: :none })

      expect(DatabaseCleaner).not_to receive(:clean)
      expect(PseudoCleaner::MasterCleaner).not_to receive(:database_reset)

      PseudoCleaner::MasterCleaner.end_example(example_object)

      RSpec::Mocks.space.proxy_for(DatabaseCleaner).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).verify
      RSpec::Mocks.space.proxy_for(DatabaseCleaner).reset
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).reset
    end

    it "only ends the test if :pseudo_delete" do
      strategy = [:pseudo_delete].sample
      example_object.instance_variable_set(:@pseudo_cleaner_data, { test_strategy: strategy, pseudo_state: cleaner_double })

      expect(DatabaseCleaner).not_to receive(:clean)
      expect(PseudoCleaner::MasterCleaner).not_to receive(:database_reset)
      expect(cleaner_double).to receive(:end).with({ test_type: :test, test_strategy: strategy }).and_return(nil)

      PseudoCleaner::MasterCleaner.end_example(example_object)

      RSpec::Mocks.space.proxy_for(DatabaseCleaner).verify
      RSpec::Mocks.space.proxy_for(DatabaseCleaner).reset
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).reset
    end

    it "resets the database if :deletion or :truncation" do
      strategy = [:deletion, :truncation].sample
      example_object.instance_variable_set(:@pseudo_cleaner_data, { test_strategy: strategy, pseudo_state: cleaner_double })

      expect(DatabaseCleaner).to receive(:clean).and_return(nil)
      expect(PseudoCleaner::MasterCleaner).to receive(:database_reset).and_return nil
      expect(cleaner_double).to receive(:end).with({ test_type: :test, test_strategy: strategy }).and_return(nil)

      PseudoCleaner::MasterCleaner.end_example(example_object)

      RSpec::Mocks.space.proxy_for(DatabaseCleaner).verify
      RSpec::Mocks.space.proxy_for(DatabaseCleaner).reset
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::MasterCleaner).reset
    end
  end

  context "single_cleaner_set = false" do
    around(:each) do |example|
      cleaner                                                          = PseudoCleaner::Configuration.current_instance.single_cleaner_set
      PseudoCleaner::Configuration.current_instance.single_cleaner_set = false

      example.run

      PseudoCleaner::Configuration.current_instance.single_cleaner_set = cleaner
    end

    describe "#start_test" do
      it "creates and starts a new MasterCleaner", strategy: :none do
        test_strategy = PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES.sample
        new_cleaner   = PseudoCleaner::MasterCleaner.new(:test)

        expect(PseudoCleaner::MasterCleaner).to receive(:new).with(:test).and_return(new_cleaner)
        expect(new_cleaner).to receive(:start).with(test_strategy, { test_type: :test, test_strategy: test_strategy })
        started_test = PseudoCleaner::MasterCleaner.start_test(test_strategy)

        expect(started_test).to eq new_cleaner
      end
    end

    describe "#clean" do
      it "cleans up created records", strategy: :none do
        mu_id    = nil
        alias_id = SearchAlias.maximum(:id)

        PseudoCleaner::MasterCleaner.clean(:test, :pseudo_delete) do
          mu_id = FactoryGirl.create(:measuring_unit).id
        end

        expect(SearchAlias.maximum(:id)).to eq alias_id
        expect(MeasuringUnit.where(id: mu_id).first).not_to be
      end

      it "re-raises any exceptions after cleaning", strategy: :none do
        mu_id    = nil
        alias_id = SearchAlias.maximum(:id)

        expect do
          PseudoCleaner::MasterCleaner.clean(:test, :pseudo_delete) do
            mu_id = FactoryGirl.create(:measuring_unit).id
            raise "this is an exception"
          end
        end.to raise_exception

        expect(SearchAlias.maximum(:id)).to eq alias_id
        expect(MeasuringUnit.where(id: mu_id).first).not_to be
      end
    end
  end

  context "single_cleaner_set = true" do
    around(:each) do |example|
      cleaner                                                          = PseudoCleaner::Configuration.current_instance.single_cleaner_set
      PseudoCleaner::Configuration.current_instance.single_cleaner_set = true

      example.run

      PseudoCleaner::Configuration.current_instance.single_cleaner_set = cleaner
    end

    describe "#start_test" do
      it "raises an exception if an invalid strategy is passed in" do
        expect { PseudoCleaner::MasterCleaner.start_test(Faker::Lorem.word) }.to raise_exception
      end

      it "calls start on @@suite_cleaner", strategy: :none do
        global_cleaner = PseudoCleaner::MasterCleaner.class_variable_get(:@@suite_cleaner)
        test_strategy  = PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES.sample

        expect(PseudoCleaner::MasterCleaner).not_to receive(:new)
        expect(global_cleaner).to receive(:start).with(test_strategy, { test_type: :test, test_strategy: test_strategy })
        started_test = PseudoCleaner::MasterCleaner.start_test(test_strategy)

        expect(started_test).to eq global_cleaner
      end
    end
  end

  describe "#reset_database" do
    it "truncates all tables and signals the database was reset", strategy: :none do
      expect(DatabaseCleaner).to receive(:clean_with)
      expect(PseudoCleaner::MasterCleaner).to receive(:database_reset)

      PseudoCleaner::MasterCleaner.reset_database
    end
  end

  describe "#database_reset" do
    it "seeds the tables and restarts the suite", strategy: :none do
      expect(PseudoCleaner::MasterCleaner).to receive(:seed_data)
      expect(PseudoCleaner::MasterCleaner).to receive(:start_suite)

      PseudoCleaner::MasterCleaner.database_reset
    end
  end

  describe "#seed_data" do
    it "seeds the tables", strategy: :none do
      expect(Seedling::Seeder).to receive(:seed_all)

      PseudoCleaner::MasterCleaner.seed_data
    end
  end

  describe "#initialize" do
    it "does not allow invalid test types" do
      expect { PseudoCleaner::MasterCleaner.new(:fred) }.to raise_exception
    end

    it "remembers the test type" do
      clean_type = [:suite, :test].sample
      cleaner    = PseudoCleaner::MasterCleaner.new(clean_type)
      expect(cleaner.instance_variable_get :@test_type).to eq clean_type
    end
  end

  context "no pre-setup cleaner_classes" do
    around(:each) do |example|
      orig_classes        = PseudoCleaner::MasterCleaner.class_variable_get(:@@cleaner_classes)
      orig_classes_sorted = PseudoCleaner::MasterCleaner.class_variable_get(:@@cleaner_classes_sorted)
      PseudoCleaner::MasterCleaner.class_variable_set(:@@cleaner_classes, nil)
      PseudoCleaner::MasterCleaner.class_variable_set(:@@cleaner_classes_sorted, false)

      example.run

      PseudoCleaner::MasterCleaner.class_variable_set(:@@cleaner_classes, orig_classes)
      PseudoCleaner::MasterCleaner.class_variable_set(:@@cleaner_classes_sorted, orig_classes_sorted)
    end

    describe "#create_table_cleaners" do
      it "creates a cleaner for every table" do
        PseudoCleaner::MasterCleaner.class_variable_set(:@@cleaner_classes, [])

        cleaner = PseudoCleaner::MasterCleaner.new(:test)
        PseudoCleaner::MasterCleaner.create_table_cleaners
        cleaner_tables = PseudoCleaner::MasterCleaner.class_variable_get(:@@cleaner_classes)

        Seedling::Seeder.create_order.each do |seed_table|
          expect(cleaner_tables.detect { |table| table[0] == seed_table }).to be_truthy
        end
        Seedling::Seeder.unclassed_tables.each do |seed_table|
          expect(cleaner_tables.detect { |table| table[1] == seed_table }).to be_truthy
        end
      end
    end

    describe "#create_custom_cleaners" do
      it "creates custom cleaner classes and sorts them" do
        FileUtils.cp_r(File.join(Rails.root, "/spec/pseudo_cleaner/rspec_fixture"),
                       File.join(Rails.root, "/db/cleaners"))

        cleaner = PseudoCleaner::MasterCleaner.new(:test)
        cleaner.start :pseudo_delete
        cleaner_tables = cleaner.instance_variable_get(:@cleaners)

        expect(cleaner_tables).not_to include(RspecFixture::BadNameCleaner)
        expect(cleaner_tables).not_to include(RspecFixture::EmptyCleaner)

        expect(cleaner_tables[0].class).to eq(RspecFixture::PreCleaner)
        expect(cleaner_tables[-1].class).to eq(RspecFixture::SimpleCleaner)
      end
    end

    describe "#start" do
      it "creates and starts cleaners" do
        cleaner = PseudoCleaner::MasterCleaner.new(:test)

        expect(PseudoCleaner::MasterCleaner).to receive(:create_table_cleaners)
        expect(PseudoCleaner::MasterCleaner).to receive(:create_custom_cleaners)
        expect(cleaner).to receive(:start_all_cleaners)

        cleaner.start :pseudo_delete
      end

      it "loads the cleaner classes only once" do
        first_cleaner = PseudoCleaner::MasterCleaner.new(:test)
        first_cleaner.start :pseudo_delete

        cleaner = PseudoCleaner::MasterCleaner.new(:test)
        expect(PseudoCleaner::MasterCleaner).not_to receive(:create_table_cleaners)
        expect(PseudoCleaner::MasterCleaner).not_to receive(:create_custom_cleaners)
        expect(cleaner).to receive(:start_all_cleaners)

        cleaner.start :pseudo_delete
      end
    end

    describe "#cleaner_classes" do
      it "initializes the class variable" do
        expect(PseudoCleaner::MasterCleaner).to receive(:create_table_cleaners)
        expect(PseudoCleaner::MasterCleaner).to receive(:create_custom_cleaners)

        PseudoCleaner::MasterCleaner.cleaner_classes

        expect(PseudoCleaner::MasterCleaner.class_variable_get(:@@cleaner_classes)).to eq []
      end
    end
  end

  describe "#end" do
    it "ends all cleaners" do
      cleaner = PseudoCleaner::MasterCleaner.new(:test)

      expect(cleaner).to receive(:end_all_cleaners)

      cleaner.end
    end
  end

  describe "#process_exception" do
    it "Outputs diagnostic information to the screen" do
      expect(PseudoCleaner::Logger).to receive(:write).at_least(1)

      PseudoCleaner::MasterCleaner.process_exception Exception.new("test")
    end
  end

  describe "#run_all_cleaners" do
    class NoFunctionsCleaner
    end

    class ExceptionCleaner
      def test_start test_strategy
        raise("This is an exception")
      end

      alias :test_end :test_start
      alias :suite_start :test_start
      alias :suite_end :test_start
    end

    class NothingCleaner
      def test_start test_strategy
      end

      alias :test_end :test_start
      alias :suite_start :test_start
      alias :suite_end :test_start
    end

    it "does not error if the cleaner doesn't respond to the function" do
      cleaner = PseudoCleaner::MasterCleaner.new(:test)

      cleaner.run_all_cleaners(:test_start, [NoFunctionsCleaner.new, NoFunctionsCleaner.new, NoFunctionsCleaner.new], :pseudo_delete)
    end

    it "runs the cleaner function" do
      cleaner  = PseudoCleaner::MasterCleaner.new(:test)
      cleaners = [NothingCleaner.new, NothingCleaner.new, NothingCleaner.new, NothingCleaner.new]

      cleaners.each do |a_cleaner|
        expect(a_cleaner).to receive(:test_start)
      end

      cleaner.run_all_cleaners(:test_start, cleaners, :pseudo_delete)
    end

    it "logs all errors except for the last and raises the last error" do
      cleaner  = PseudoCleaner::MasterCleaner.new(:test)
      cleaners = [ExceptionCleaner.new, ExceptionCleaner.new, ExceptionCleaner.new, ExceptionCleaner.new]

      expect(PseudoCleaner::MasterCleaner).to receive(:process_exception).exactly(3).times

      expect { cleaner.run_all_cleaners(:test_start, cleaners, :pseudo_delete) }.to raise_exception
    end
  end

  describe "#reset_suite" do
    it "calls run_all_cleaners" do
      cleaner = PseudoCleaner::MasterCleaner.new(:test)
      cleaner.instance_variable_set(:@cleaners, [])
      expect(cleaner).to receive(:run_all_cleaners).with(:reset_suite, []).and_return(nil)

      cleaner.reset_suite
    end
  end

  describe "#cleaner_class" do
    before(:each) do
      FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/measuring_unit_cleaner.rb"))

      if Object.const_defined?("MeasuringUnitCleaner", false)
        Object.send(:remove_const, "MeasuringUnitCleaner")
      end
    end

    after(:each) do
      FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/measuring_unit_cleaner.rb"))

      if Object.const_defined?("MeasuringUnitCleaner", false)
        Object.send(:remove_const, "MeasuringUnitCleaner")
      end
    end

    if rand(1..2) == 1
      it "finds a named table cleaner_class in db/cleaners" do
        FileUtils.mkdir_p(File.join(Rails.root, "/db/cleaners/"))
        FileUtils.cp(File.join(Rails.root, "/spec/pseudo_cleaner/rspec_fixture/measuring_unit_cleaner.rb"),
                     File.join(Rails.root, "/db/cleaners/measuring_unit_cleaner.rb"))

        expect(PseudoCleaner::MasterCleaner.cleaner_class(MeasuringUnit).name).to eq("MeasuringUnitCleaner")
      end
    else
      it "does not find a cleaner class if it does not have a valid function" do
        FileUtils.mkdir_p(File.join(Rails.root, "/db/cleaners/"))
        FileUtils.cp(File.join(Rails.root, "/spec/pseudo_cleaner/rspec_fixture/empty_measuring_unit_cleaner.rb"),
                     File.join(Rails.root, "/db/cleaners/measuring_unit_cleaner.rb"))

        expect(PseudoCleaner::MasterCleaner.cleaner_class(MeasuringUnit)).to eq PseudoCleaner::TableCleaner
      end
    end

    it "returns PseudoCleaner::TableCleaner if there is no file" do
      expect(PseudoCleaner::MasterCleaner.cleaner_class(MeasuringUnit)).to eq PseudoCleaner::TableCleaner
    end
  end
end