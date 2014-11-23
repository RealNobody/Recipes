require "rails_helper"

class CompareGreater
  def self.<=>(right_object)
    1
  end
end

class CompareLesser
  def self.<=>(right_object)
    -1
  end
end

RSpec.describe PseudoCleaner::TableCleaner do
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
  end

  after(:each) do
    FileUtils.rm_rf(File.join(Rails.root, "/db/cleaners/rspec_fixture"))
  end

  context "pre-setup initial_states" do
    describe "#initialize" do
      it "does not set @table_is_active_record" do
        diagnostics_val = [true, false].sample

        PseudoCleaner::Configuration.current_instance.output_diagnostics = diagnostics_val

        expect(ActiveRecord).not_to receive(:const_defined?)
        cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)

        expect(cleaner.instance_variable_get(:@options)[:table_start_method]).to eq(:test_start)
        expect(cleaner.instance_variable_get(:@options)[:table_end_method]).to eq(:test_end)
        expect(cleaner.instance_variable_get(:@options)[:output_diagnostics]).to eq(diagnostics_val)
        expect(cleaner.table).to eq(MeasuringUnit)
      end
    end

    describe "#reset_suite" do
      it "does nothing if the initial data is already saved" do
        cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)

        cleaner.reset_suite
        expect(PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)).to eq({})
      end
    end

    [:test_start, :suite_start].each do |start_method|
      describe "##{start_method}" do
        it "does nothing if the initial data is already saved" do
          cleaner = PseudoCleaner::TableCleaner.new(start_method, :test_end, MeasuringUnit)

          expect(cleaner).not_to receive(:test_start_active_record)
          cleaner.send(start_method, :pseudo_delete)

          RSpec::Mocks.space.proxy_for(cleaner).verify
          RSpec::Mocks.space.proxy_for(cleaner).reset
        end
      end
    end
  end

  context "no pre-setup initial_states" do
    before(:each) do |example|
      @orig_states = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)
      PseudoCleaner::TableCleaner.class_variable_set(:@@initial_states, {})
    end

    after(:each) do |example|
      PseudoCleaner::TableCleaner.class_variable_set(:@@initial_states, @orig_states)
    end

    describe "#initialize" do
      it "sets @table_is_active_record" do
        diagnostics_val = [true, false].sample

        PseudoCleaner::Configuration.current_instance.output_diagnostics = diagnostics_val

        cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)

        initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[MeasuringUnit]

        expect(initial_state[:table_is_active_record]).to be_truthy
        expect(initial_state[:table_is_sequel_model]).to be_falsey
        expect(initial_state[:table_name]).to eq "MeasuringUnit"

        expect(cleaner.instance_variable_get(:@options)[:table_start_method]).to eq(:test_start)
        expect(cleaner.instance_variable_get(:@options)[:table_end_method]).to eq(:test_end)
        expect(cleaner.instance_variable_get(:@options)[:output_diagnostics]).to eq(diagnostics_val)
        expect(cleaner.table).to eq(MeasuringUnit)
      end

      it "accepts a symbol" do
        diagnostics_val = [true, false].sample

        PseudoCleaner::Configuration.current_instance.output_diagnostics = diagnostics_val

        cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, :measuring_units)

        initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[:measuring_units]

        expect(initial_state[:table_is_active_record]).to be_truthy
        expect(initial_state[:table_is_sequel_model]).to be_falsey
        expect(initial_state[:table_name]).to eq :measuring_units

        expect(cleaner.instance_variable_get(:@options)[:table_start_method]).to eq(:test_start)
        expect(cleaner.instance_variable_get(:@options)[:table_end_method]).to eq(:test_end)
        expect(cleaner.instance_variable_get(:@options)[:output_diagnostics]).to eq(diagnostics_val)
        expect(cleaner.table).to eq(:measuring_units)
      end
    end

    [:test_start, :suite_start].each do |start_method|
      describe "##{start_method}" do
        (PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES - [:pseudo_delete]).each do |strategy|
          it "does nothing if the strategy is #{strategy}" do
            cleaner = PseudoCleaner::TableCleaner.new(start_method, :test_end, MeasuringUnit)

            expect(cleaner).not_to receive(:test_start_active_record)
            cleaner.send(start_method, strategy)

            RSpec::Mocks.space.proxy_for(cleaner).verify
            RSpec::Mocks.space.proxy_for(cleaner).reset
          end
        end

        it "saves basic initialization information" do
          cleaner = PseudoCleaner::TableCleaner.new(start_method, :test_end, MeasuringUnit)

          expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(5).times

          cleaner.send(start_method, :pseudo_delete)

          RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
          RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset

          initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[MeasuringUnit]

          expect(initial_state).to be
          expect(initial_state[:saved]).to be_truthy
          expect(initial_state[:max_id]).to be
          expect(initial_state[:created][:column_name]).to eq("created_at")
          expect(initial_state[:created][:value]).to be
          expect(initial_state[:updated][:column_name]).to eq("updated_at")
          expect(initial_state[:updated][:value]).to be
          expect(initial_state[:count]).to be
          expect(initial_state[:blank]).to be_falsey
        end

        it "saves basic initialization information for symbols" do
          cleaner = PseudoCleaner::TableCleaner.new(start_method, :test_end, :measuring_units)

          expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(5).times

          cleaner.send(start_method, :pseudo_delete)

          RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
          RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset

          initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[:measuring_units]

          expect(initial_state).to be
          expect(initial_state[:saved]).to be_truthy
          expect(initial_state[:max_id]).to be
          expect(initial_state[:created][:column_name]).to eq("created_at")
          expect(initial_state[:created][:value]).to be
          expect(initial_state[:updated][:column_name]).to eq("updated_at")
          expect(initial_state[:updated][:value]).to be
          expect(initial_state[:count]).to be
          expect(initial_state[:blank]).to be_falsey
        end

        it "saves a count of rows if no date or id columns exist" do
          cleaner = PseudoCleaner::TableCleaner.new(start_method, :test_end, MeasuringUnit)

          allow(ActiveRecord::Base.connection).to receive(:columns).with("measuring_units").and_return([])
          cleaner.send(start_method, :pseudo_delete)

          initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[MeasuringUnit]

          expect(initial_state).to be
          expect(initial_state[:saved]).to be_truthy
          expect(initial_state[:max_id]).not_to be
          expect(initial_state[:created]).not_to be
          expect(initial_state[:updated]).not_to be
          expect(initial_state[:count]).to be
          expect(initial_state[:blank]).to be_truthy
        end
      end
    end
  end

  describe "#initialize" do
    it "creates an instance" do
      expect { PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit) }.not_to raise_exception
    end

    it "sets @table_is_active_record" do
      module SomeModule
        module AnotherModule
          class SomeRecord < ActiveRecord::Base
          end
        end
      end

      class DerivedClass < SomeModule::AnotherModule::SomeRecord
      end

      cleaner       = PseudoCleaner::TableCleaner.new(:test_start, :test_end, DerivedClass)
      initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[DerivedClass]

      expect(initial_state[:table_is_active_record]).to be_truthy
    end

    it "requires a table" do
      expect { PseudoCleaner::TableCleaner.new(:test_start, :test_end, nil) }.to raise_exception
    end

    it "requires a valid start function" do
      expect { PseudoCleaner::TableCleaner.new(:fake_start, :test_end, MeasuringUnit) }.to raise_exception
    end

    it "requires a valid end function" do
      expect { PseudoCleaner::TableCleaner.new(:test_start, :fake_end, MeasuringUnit) }.to raise_exception
    end
  end

  [:test, :suite].each do |start_method|
    describe "##{start_method}_end" do
      (PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES - [:pseudo_delete]).each do |strategy|
        (PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES - [:pseudo_delete, strategy]).each do |end_strategy|
          it "does not allow mis-matched end strategy #{end_strategy} with start strategy #{strategy}" do
            cleaner = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                      "#{start_method}_end".to_sym,
                                                      MeasuringUnit)

            expect(cleaner).not_to receive(:test_start_active_record)
            expect(cleaner).not_to receive(:test_end_active_record)
            cleaner.send("#{start_method}_start", strategy)

            expect(PseudoCleaner::Logger).not_to receive(:write)
            cleaner.send("#{start_method}_end", end_strategy)

            RSpec::Mocks.space.proxy_for(cleaner).verify
            RSpec::Mocks.space.proxy_for(cleaner).reset
            RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
            RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset
          end
        end
      end

      (PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES).each do |strategy|
        (PseudoCleaner::MasterCleaner::CLEANING_STRATEGIES - [:pseudo_delete, strategy]).each do |end_strategy|
          next unless end_strategy == :pseudo_delete

          it "does nothing if strategy is #{strategy} and end_strategy #{end_strategy}" do
            cleaner = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                      "#{start_method}_end".to_sym,
                                                      MeasuringUnit)

            cleaner.send("#{start_method}_start", strategy)

            expect_count = 2
            expect_count += 1 if strategy == end_strategy

            expect(cleaner).not_to receive("#{start_method}_end_active_record".to_sym)
            expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(expect_count).times
            cleaner.send("#{start_method}_end", end_strategy)

            RSpec::Mocks.space.proxy_for(cleaner).verify
            RSpec::Mocks.space.proxy_for(cleaner).reset
          end
        end
      end

      it "deletes new records if id is larger" do
        alias_id = SearchAlias.maximum(:id)
        cleaner  = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                   "#{start_method}_end".to_sym,
                                                   MeasuringUnit)

        cleaner.send("#{start_method}_start", :pseudo_delete)
        test_mu = FactoryGirl.create(:measuring_unit)
        cleaner.send("#{start_method}_end", :pseudo_delete)

        new_mu = MeasuringUnit.where(id: test_mu.id).first
        expect(new_mu).not_to be
        expect(SearchAlias.maximum(:id)).to be > alias_id
      end

      it "deletes new records if created_at is larger" do
        alias_id = SearchAlias.maximum(:id)
        cleaner  = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                   "#{start_method}_end".to_sym,
                                                   MeasuringUnit)

        cleaner.send("#{start_method}_start", :pseudo_delete)
        FactoryGirl.create(:measuring_unit, id: -2)
        test_mu = FactoryGirl.create(:measuring_unit)
        cleaner.send("#{start_method}_end", :pseudo_delete)

        new_mu = MeasuringUnit.where(id: test_mu.id).first
        expect(new_mu).not_to be

        new_mu = MeasuringUnit.where(id: -2).first
        expect(new_mu).not_to be
        expect(SearchAlias.maximum(:id)).to be > alias_id
      end

      it "warns if existing records updated" do
        cleaner = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                  "#{start_method}_end".to_sym,
                                                  MeasuringUnit)

        cleaner.send("#{start_method}_start", :pseudo_delete)

        mu            = MeasuringUnit.first
        mu.updated_at = Time.now + 2.seconds
        mu.save

        expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(2).times
        cleaner.send("#{start_method}_end", :pseudo_delete)

        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset
      end

      it "warns if a new record was added that it can't determine" do
        alias_id = SearchAlias.maximum(:id)
        cleaner  = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                   "#{start_method}_end".to_sym,
                                                   MeasuringUnit)

        cleaner.send("#{start_method}_start", :pseudo_delete)
        initial_states = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)
        initial_state  = initial_states[MeasuringUnit]

        new_state = initial_state.clone
        new_state.delete(:max_id)
        new_state.delete(:updated)
        new_state.delete(:created)
        new_state[:count]             = MeasuringUnit.count
        new_state[:blank]             = true
        initial_states[MeasuringUnit] = new_state

        test_mu = FactoryGirl.create(:measuring_unit)

        expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(2).times
        cleaner.send("#{start_method}_end", :pseudo_delete)

        new_mu = MeasuringUnit.where(id: test_mu.id).first
        expect(new_mu).to be
        expect(SearchAlias.maximum(:id)).to be > alias_id

        test_mu.destroy
        initial_states[MeasuringUnit] = initial_state

        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset
      end

      it "deletes all records if record was added that it can't determine but was previously empty",
         strategy: :pseudo_delete do
        alias_id = SearchAlias.maximum(:id)
        cleaner  = PseudoCleaner::TableCleaner.new("#{start_method}_start".to_sym,
                                                   "#{start_method}_end".to_sym,
                                                   :recipes)

        cleaner.send("#{start_method}_start", :pseudo_delete)
        initial_states = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)
        initial_state  = initial_states[:recipes]
        new_state      = initial_state.clone

        new_state.delete(:max_id)
        new_state.delete(:updated)
        new_state.delete(:created)
        new_state[:count]        = Recipe.count
        new_state[:blank]        = true
        initial_states[:recipes] = new_state

        expect(new_state[:count]).to eq 0

        test_mu = FactoryGirl.create(:recipe)

        expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(2).times
        cleaner.send("#{start_method}_end", :pseudo_delete)

        new_mu = Recipe.where(id: test_mu.id).first
        expect(new_mu).not_to be
        expect(SearchAlias.maximum(:id)).to be > alias_id

        initial_states[:recipes] = initial_state

        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
        RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset
      end
    end
  end

  describe "#reset_auto_increment" do
    it "does nothing if test_start is false" do
      cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)
      expect(cleaner).not_to receive(:reset_auto_increment_active_record)
      cleaner.reset_auto_increment(false)
    end

    it "resets the auto increment if there is an id" do
      cleaner = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)
      expect(cleaner).to receive(:reset_auto_increment_active_record).and_call_original
      expect(PseudoCleaner::Logger).to receive(:write).and_call_original.exactly(1).times
      cleaner.reset_auto_increment(true)

      RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset
    end

    it "does not reset the auto increment if there is not an id" do
      cleaner       = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)
      initial_state = PseudoCleaner::TableCleaner.class_variable_get(:@@initial_states)[MeasuringUnit]
      id            = initial_state.delete(:max_id)

      expect(cleaner).to receive(:reset_auto_increment_active_record).and_call_original
      expect(PseudoCleaner::Logger).not_to receive(:write)

      cleaner.reset_auto_increment(true)

      RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).verify
      RSpec::Mocks.space.proxy_for(PseudoCleaner::Logger).reset

      initial_state[:max_id] = id
    end
  end

  describe "#<=>" do
    it "returns 0 if the tables are the same" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)
      right_obj = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)

      expect(left_obj <=> right_obj).to eq(0)
    end

    it "returns -1 if the left table seeds before the right table" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)
      right_obj = PseudoCleaner::TableCleaner.new(:test_start, :test_end, Ingredient)

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 if the left table seeds after the right table" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, Ingredient)
      right_obj = PseudoCleaner::TableCleaner.new(:test_start, :test_end, MeasuringUnit)

      expect(left_obj <=> right_obj).to eq(1)
    end

    it "returns -1 if the other object doesn't respond to <=>" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, Ingredient)
      right_obj = PseudoCleaner::TableCleaner

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns -1 if the other object responds to <=> and returns -1" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, Ingredient)
      right_obj = CompareGreater

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 if the other object responds to <=> and returns 1" do
      left_obj  = PseudoCleaner::TableCleaner.new(:test_start, :test_end, Ingredient)
      right_obj = CompareLesser

      expect(left_obj <=> right_obj).to eq(1)
    end
  end
end