require 'spec_helper'
require "seedling"

# interestingly, since this is inside of my test suites, the class being tested
# is used around each of the tests.
#
# So, one would expect an error to be thrown before the test could run.
#
# TODO: Generic tests
# Really, this test is rotten, because I'm testing based mostly on my DB
# schema.  It isn't that the class is dependent on my schema, just that
# because it uses a DB schema, I don't know how to test it without
# one, and I don't know how to create one to test it with.  I should
# probably take a look at how db_cleaner gem does their tests someday.
# For now, this is good enough for me.  (I'm not a gem, am I?)

describe Seedling do
  after(:each) do
    Seedling.class_variable_set("@@create_order", nil)
  end

  describe "class methods" do
    it "#seed_all should call #seed on all tables" do
      Seedling.stub(create_order: [MeasuringUnit, User, PrepOrder])

      Seedling.should_receive(:seed).with(MeasuringUnit)
      Seedling.should_receive(:seed).with(User)
      Seedling.should_receive(:seed).with(PrepOrder)

      Seedling.seed_all
    end

    it "#seed should call #seed on the table if it responds to #seed" do
      User.should_receive(:respond_to?).with(:seed).and_return(true)
      User.should_receive(:seed).and_return(nil)
      Seedling.seed(User)
    end

    it "#seed should not call #seed on the table if it does not respond to #seed" do
      MeasuringUnit.should_receive(:respond_to?).with(:seed).and_return(false)
      MeasuringUnit.should_not_receive(:seed)
      Seedling.seed(MeasuringUnit)
    end

    it "#test_start should create a new seedling" do
      Seedling.should_receive(:new).with(:test_start, :test_end).and_return(nil)
      Seedling.test_start
    end

    it "#suite_start should create a new seedling" do
      Seedling.should_receive(:new).with(:suite_start, :suite_end).and_return(nil)
      Seedling.suite_start
    end

    it "#create_order should order tables" do
      Seedling.class_variable_set("@@create_order", nil)
      ActiveRecord::Base.connection.stub(tables: ["measurement_conversions", "measuring_units"])
      ordered_tables = Seedling.create_order
      expect(ordered_tables).to eq([MeasuringUnit, MeasurementConversion])
    end

    it "#pre_table should return a table that should be seeded before another table" do
      Seedling.class_variable_set("@@create_order", [])

      pre_class = Seedling.pre_table(Ingredient)
      unless(pre_class == MeasuringUnit)
        expect(pre_class).to eq(IngredientCategory)
      end
    end

    it "#pre_table should not return a table was previously returned" do
      Seedling.class_variable_set("@@create_order", [MeasuringUnit])

      pre_class = Seedling.pre_table(Ingredient)
      expect(pre_class).to eq(IngredientCategory)
    end
  end

  describe "instance methods" do
    let(:single_seedling) { Seedling.new(:test_start, :test_end, MeasuringUnit) }

    describe "#initialize" do
      it "should create an array of seedlings if no table specified" do
        Seedling.class_variable_set("@@create_order", [MeasuringUnit, User])

        seedling = Seedling.new :test_start, :test_end

        expect(seedling.instance_variable_get("@seedlings").length).to be 2
        expect(seedling.instance_variable_get("@table")).to_not be
        expect(seedling.instance_variable_get("@max_id")).to_not be
      end

      it "should initialize for a single table" do
        expect(single_seedling.instance_variable_get("@seedlings")).to_not be
        expect(single_seedling.instance_variable_get("@table")).to eq(MeasuringUnit)
        expect(single_seedling.instance_variable_get("@max_id")).to be
      end

      it "should call #test_start when initialized with a table" do
        Seedling.any_instance.should_receive(:my_start_function).and_return "fred is silly"

        seedling = Seedling.new :my_start_function, :test_end, MeasuringUnit
      end
    end

    describe "aliased methods" do
      it "should respond to suite_start" do
        expect(single_seedling.respond_to?(:suite_start)).to be_true
      end

      it "should respond to suite_end" do
        expect(single_seedling.respond_to?(:suite_end)).to be_true
      end
    end

    describe "#test_start" do
      it "should save the tables max_id" do
        max = MeasuringUnit.order(:id).last.id
        single_seedling.test_start
        expect(single_seedling.instance_variable_get("@max_id")).to eq max
      end

      it "should allow the table to do something special on test_start" do
        MeasuringUnit.should_receive(:test_start).and_return("this is a test")

        expect(single_seedling.instance_variable_get("@max_id")).to eq "this is a test"
      end
    end

    describe "#test_end" do
      it "should delete any record > @max_id if a single instance" do
        max = MeasuringUnit.order(:id).last.id
        single_seedling
        new_obj = FactoryGirl.create(:measuring_unit)
        new_id = new_obj.id
        expect(new_id).to be > max

        single_seedling.test_end
        expect(MeasuringUnit.where(id: new_id).length).to be <= 0
      end

      it "should be called for all tables if not a single instance" do
        Seedling.class_variable_set("@@create_order", [MeasuringUnit, User])

        seedling = Seedling.new :test_start, :test_end
        sub_seedlings = seedling.instance_variable_get("@seedlings")
        sub_seedlings[0].should_receive(:test_end).and_call_original
        sub_seedlings[1].should_receive(:test_end).and_call_original

        seedling.test_end
      end

      it "should allow the table to do something special on test_end" do
        my_seedling = Seedling.new(:test_end, :test_end, MeasuringUnit)

        my_seedling.instance_variable_set("@max_id", "this is a test")

        MeasuringUnit.should_receive(:test_end).with("this is a test")
        my_seedling.test_end
      end
    end
  end
end