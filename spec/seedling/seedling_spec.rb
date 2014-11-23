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

RSpec.describe Seedling::Seeder do
  before(:each) do
    FileUtils.rm_rf(File.join(Rails.root, "/db/seeders/rspec_fixture"))
  end

  after(:each) do
    FileUtils.rm_rf(File.join(Rails.root, "/db/seeders/rspec_fixture"))
  end

  describe Seedling::Seeder::SeederSorter do
    it "returns <=> if left objects respond to it" do
      left_obj  = Seedling::Seeder::SeederSorter.new(Seedling::Seeder.new(MeasuringUnit, Seedling::Seeder.seed_class(MeasuringUnit)))
      right_obj = Seedling::Seeder::SeederSorter.new(Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient)))

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "sorts by class name if both are classes" do
      left_obj  = Seedling::Seeder::SeederSorter.new(MeasuringUnit)
      right_obj = Seedling::Seeder::SeederSorter.new(Ingredient)

      expect(left_obj <=> right_obj).to eq(1)
    end

    it "returns -1 <=> if right object returns 1" do
      left_obj  = Seedling::Seeder::SeederSorter.new(MeasuringUnit)
      right_obj = Seedling::Seeder::SeederSorter.new(CompareGreater)

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 <=> if right object returns -1" do
      left_obj  = Seedling::Seeder::SeederSorter.new(MeasuringUnit)
      right_obj = Seedling::Seeder::SeederSorter.new(CompareLesser)

      expect(left_obj <=> right_obj).to eq(1)
    end

    it "returns -1 <=> if left object is not a class" do
      left_obj  = Seedling::Seeder::SeederSorter.new(1)
      right_obj = Seedling::Seeder::SeederSorter.new(MeasuringUnit)

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 <=> if right object is not a class" do
      left_obj  = Seedling::Seeder::SeederSorter.new(MeasuringUnit)
      right_obj = Seedling::Seeder::SeederSorter.new(1)

      expect(left_obj <=> right_obj).to eq(1)
    end

    it "returns 0 <=> if both objects are not classes" do
      left_obj  = Seedling::Seeder::SeederSorter.new("fred")
      right_obj = Seedling::Seeder::SeederSorter.new(1)

      expect(left_obj <=> right_obj).to eq(0)
    end
  end

  describe "#create_order" do
    before(:each) do
      Seedling::Seeder.class_variable_set("@@create_order", nil)
    end

    after(:each) do
      Seedling::Seeder.class_variable_set("@@create_order", nil)
    end

    it "should order related tables" do
      allow(ActiveRecord::Base.connection).to receive_messages(tables: ["measurement_conversions", "measuring_units"])

      ordered_tables = Seedling::Seeder.create_order

      expect(ordered_tables).to eq([MeasuringUnit, MeasurementConversion])
    end

    it "should order polymorphic tables" do
      allow(ActiveRecord::Base.connection).to receive_messages(tables: ["search_aliases",
                                                                        "measurement_conversions",
                                                                        "ingredients",
                                                                        "measuring_units",
                                                                        "ingredient_categories",
                                                                       ])

      ordered_tables = Seedling::Seeder.create_order

      expect(ordered_tables).to eq([MeasuringUnit,
                                    IngredientCategory,
                                    Ingredient,
                                    SearchAlias,
                                    MeasurementConversion
                                   ])
    end
  end

  describe "#pre_table" do
    before(:each) do
      Seedling::Seeder.class_variable_set("@@create_order", [])
    end

    after(:each) do
      Seedling::Seeder.class_variable_set("@@create_order", nil)
    end

    it "should return a table that should be seeded before another table" do
      create_order = Seedling::Seeder.class_variable_get("@@create_order")

      pre_class = Seedling::Seeder.active_record_pre_table(Ingredient, {}, [])
      create_order << pre_class

      unless (pre_class == MeasuringUnit)
        expect(pre_class).to eq(IngredientCategory)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(Ingredient, {}, [])
      create_order << pre_class

      unless (pre_class == MeasuringUnit)
        expect(pre_class).to eq(IngredientCategory)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(Ingredient, {}, [])
      create_order << pre_class

      expect(pre_class).not_to be
    end

    it "should return polymporphic table pre-conditions pre-conditions" do
      create_order = Seedling::Seeder.class_variable_get("@@create_order")

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [Ingredient] }, [])
      create_order << pre_class

      unless (pre_class == MeasuringUnit)
        expect(pre_class).to eq(IngredientCategory)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [Ingredient] }, [])
      create_order << pre_class

      unless (pre_class == MeasuringUnit)
        expect(pre_class).to eq(IngredientCategory)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [Ingredient] }, [])
      create_order << pre_class

      expect(pre_class).to eq(Ingredient)

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [Ingredient] }, [])
      create_order << pre_class

      expect(pre_class).not_to be
    end

    it "should return polymporphic table pre-conditions if no other pre-conditions" do
      create_order = Seedling::Seeder.class_variable_get("@@create_order")

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [RecipeType, Container] }, [])
      create_order << pre_class

      unless (pre_class == RecipeType)
        expect(pre_class).to eq(Container)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [RecipeType, Container] }, [])
      create_order << pre_class

      unless (pre_class == RecipeType)
        expect(pre_class).to eq(Container)
      end

      pre_class = Seedling::Seeder.active_record_pre_table(SearchAlias, { "SearchAlias" => [RecipeType, Container] }, [])
      create_order << pre_class

      expect(pre_class).not_to be
    end
  end

  describe "#seed_class" do
    it "finds a named table seed_class in db/seeds" do
      expect(Seedling::Seeder.seed_class(MeasuringUnit).name).to eq("MeasuringUnitSeeder")
    end

    it "does not find the table even if the table responds to #seed" do
      allow(Object).to receive(:const_defined?).with("MeasuringUnitSeeder", false).and_return(false)
      allow(File).to receive(:exists?).and_return(false)

      class MeasuringUnit
        def self.seed
        end
      end

      expect(Seedling::Seeder.seed_class(MeasuringUnit)).not_to be
    end

    it "returns nil if there is no file and the table doesn't respond to seed" do
      allow(Object).to receive(:const_defined?).with("MeasuringUnitSeeder", false).and_return(false)
      allow(File).to receive(:exists?).and_return(false)
      allow(MeasuringUnit).to receive(:respond_to?).with(:seed).and_return(false)

      expect(Seedling::Seeder.seed_class(MeasuringUnit)).not_to be
    end
  end

  describe "#<=>" do
    it "returns 0 if the tables are the same" do
      left_obj  = Seedling::Seeder.new(MeasuringUnit, Seedling::Seeder.seed_class(MeasuringUnit))
      right_obj = Seedling::Seeder.new(MeasuringUnit, Seedling::Seeder.seed_class(MeasuringUnit))

      expect(left_obj <=> right_obj).to eq(0)
    end

    it "returns -1 if the left table seeds before the right table" do
      left_obj  = Seedling::Seeder.new(MeasuringUnit, Seedling::Seeder.seed_class(MeasuringUnit))
      right_obj = Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient))

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 if the left table seeds after the right table" do
      left_obj  = Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient))
      right_obj = Seedling::Seeder.new(MeasuringUnit, Seedling::Seeder.seed_class(MeasuringUnit))

      expect(left_obj <=> right_obj).to eq(1)
    end

    it "returns -1 if the other object doesn't respond to <=>" do
      left_obj  = Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient))
      right_obj = Seedling::Seeder

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns -1 if the other object responds to <=> and returns -1" do
      left_obj  = Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient))
      right_obj = CompareGreater

      expect(left_obj <=> right_obj).to eq(-1)
    end

    it "returns 1 if the other object responds to <=> and returns 1" do
      left_obj  = Seedling::Seeder.new(Ingredient, Seedling::Seeder.seed_class(Ingredient))
      right_obj = CompareLesser

      expect(left_obj <=> right_obj).to eq(1)
    end
  end

  describe "#seed" do
    it "deals with it if there is no seed class" do
      subject = Seedling::Seeder.new(SearchAlias, Seedling::Seeder.seed_class(SearchAlias))
      expect { subject.seed }.not_to raise_exception
    end

    it "deals with it if there is no seed class" do
      seed_class = Seedling::Seeder.seed_class(MeasuringUnit)
      subject    = Seedling::Seeder.new(MeasuringUnit, seed_class)

      allow(Seedling::Seeder).to receive(:seed_class).and_return(seed_class)
      expect(seed_class).to receive(:seed).and_return(nil)

      expect { subject.seed }.not_to raise_exception
    end
  end

  describe "#seeder_classes" do
    before(:each) do
      allow(ActiveRecord::Base.connection).to receive_messages(tables: ["measurement_conversions",
                                                                        "measuring_units",
                                                                        "search_aliases"])

      Seedling::Seeder.class_variable_set("@@seeder_classes", nil)
      Seedling::Seeder.class_variable_set("@@create_order", nil)
    end

    after(:each) do
      Seedling::Seeder.class_variable_set("@@seeder_classes", nil)
      Seedling::Seeder.class_variable_set("@@create_order", nil)
    end

    it "creates a sorted Seeder class for each table object that seeds" do
      seeders = Seedling::Seeder.seeder_classes

      expect(seeders[0].table).to eq(MeasuringUnit)
      expect(seeders[1].table).to eq(MeasurementConversion)
      expect(seeders[2].table).to eq(SearchAlias)
      expect(seeders).not_to include(MeasuringUnit)
      expect(seeders).not_to include(MeasurementConversion)
    end

    it "creates custom seeder classes and sorts them" do
      FileUtils.cp_r(File.join(Rails.root, "/spec/seedling/rspec_fixture"),
                     File.join(Rails.root, "/db/seeders"))

      seeders = Seedling::Seeder.seeder_classes

      expect(seeders).not_to include(RspecFixture::BadNameSeeder)
      expect(seeders).not_to include(RspecFixture::EmptySeeder)

      expect(seeders[0]).to eq(RspecFixture::PreSeeder)

      simple_index = seeders.find_index(RspecFixture::SimpleSeeder)
      expect(seeders[simple_index - 1].name).to be < RspecFixture::SimpleSeeder.name
      expect(seeders[simple_index + 1].name).to be > RspecFixture::SimpleSeeder.name
    end
  end

  describe "#seed_all" do
    it "calls seed on all seeder_classes" do
      seeder_1 = double(:seeder_1, seed: 1)
      seeder_2 = double(:seeder_1, seed: 2)

      expect(seeder_1).to receive(:seed).and_return nil
      expect(seeder_2).to receive(:seed).and_return nil
      expect(Seedling::Seeder).to receive(:seeder_classes).and_return([seeder_1, seeder_2])

      Seedling::Seeder.seed_all
    end
  end
end