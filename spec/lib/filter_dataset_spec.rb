require 'rails_helper'
require "filter_dataset"

################################################################################
#
# A collection of fake database classes to simulate tables with relationships
# which we don't have in the current database.
#
# Some are "good", most are examples which will cause problems.

# An example of a has_many :through relationship
class HasManyThroughMeasuringUnit < ActiveRecord::Base
  self.table_name = "measuring_units"

  has_many :larger_measurement_conversions,
           dependent:   :delete_all,
           class_name:  "MeasurementConversion",
           foreign_key: :smaller_measuring_unit_id
  has_many :smaller_measurement_conversions,
           dependent:   :delete_all,
           class_name:  "MeasurementConversion",
           foreign_key: :larger_measuring_unit_id

  has_many :larger_measuring_units,
           through:    :larger_measurement_conversions,
           class_name: "HasManyThroughMeasuringUnit"
  has_many :smaller_measuring_units,
           through:    :smaller_measurement_conversions,
           class_name: "HasManyThroughMeasuringUnit"
end

# Used to test that the system will raise an error if the table doesn't exist but the class does
class FakeTable < ActiveRecord::Base
end

# An example of a has_one relationship
class HasOneRecipeType < ActiveRecord::Base
  self.table_name = "recipe_types"

  has_one :recipe
end

# A set of three classes used to test has_one through
class HasOneThroughIngredient < ActiveRecord::Base
  self.table_name = "ingredients"
end

class HasOneThroughRecipe < ActiveRecord::Base
  self.table_name = "recipes"

  has_one :has_one_through_ingredient, foreign_key: :ingredient_type_id
end

class HasOneThroughRecipeType < ActiveRecord::Base
  self.table_name = "recipe_types"

  has_one :has_one_through_recipe, foreign_key: :recipe_type_id
  has_one :has_one_through_ingredient, through: :has_one_through_recipe
end

# A class to test too many relationships to the same class using different relationship types
class TooManyMeasuringUnit < ActiveRecord::Base
  self.table_name = "measuring_units"

  has_many :larger_measurement_conversions,
           class_name:  "MeasurementConversion",
           foreign_key: :smaller_measuring_unit_id
  has_one  :smaller_measurement_conversions,
           class_name:  "MeasurementConversion",
           foreign_key: :larger_measuring_unit_id
end

################################################################################

RSpec.describe FilterDataset do
  let(:mu_dataset) { FilterDataset.new(:measuring_units, nil) }
  let(:mu_through_dataset) { FilterDataset.new(:has_many_through_measuring_units, nil) }
  let(:ig_dataset) { FilterDataset.new(:ingredients, nil) }
  let(:alias_dataset) { FilterDataset.new(:search_aliases, nil) }
  let(:has_one_dataset) { FilterDataset.new(:has_one_recipe_types, nil) }
  let(:has_one_through_dataset) { FilterDataset.new(:has_one_through_recipe_types, nil) }
  let(:has_too_many_dataset) { FilterDataset.new(:too_many_measuring_units, nil) }

  describe "#split_field" do
    it "treats a single value as a field name" do
      table_name, field_name, alias_name = mu_dataset.split_field(:a_field_name)

      expect(table_name).to be_nil
      expect(field_name).to be == :a_field_name
      expect(alias_name).to be_nil
    end

    it "treats a string the same as a symbol" do
      table_name, field_name, alias_name = mu_dataset.split_field("a_field_name")

      expect(table_name).to be_nil
      expect(field_name).to be == :a_field_name
      expect(alias_name).to be_nil
    end

    it "extracts an alias and a field_name" do
      table_name, field_name, alias_name = mu_dataset.split_field(:a_field_name___field_alias)

      expect(table_name).to be_nil
      expect(field_name).to be == :a_field_name
      expect(alias_name).to be == :field_alias
    end

    it "extracts a table and a field_name" do
      table_name, field_name, alias_name = mu_dataset.split_field(:table_name__a_field_name)

      expect(table_name).to be == :table_name
      expect(field_name).to be == :a_field_name
      expect(alias_name).to be_nil
    end

    it "extracts a table and a field_name and an alias" do
      table_name, field_name, alias_name = mu_dataset.split_field("table_name__a_field_name___field_alias")

      expect(table_name).to be == :table_name
      expect(field_name).to be == :a_field_name
      expect(alias_name).to be == :field_alias
    end
  end

  describe "#field_information" do
    it "retrieves the field information from the model" do
      field_info = mu_dataset.field_information(nil, :name)

      expect(field_info[:name]).to be == :measuring_units__name
      expect(field_info[:type]).to be == :string
    end

    describe "#belongs_to" do
      it "retrieves the field info and basic join information from a simple belongs_to" do
        field_info = ig_dataset.field_information(:measuring_units, :name)

        expect(field_info[:name]).to be == :measuring_units_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 1
        expect(field_info[:join_info][0][:table_name]).to be == :measuring_units
        expect(field_info[:join_info][0][:table_alias]).to be == :measuring_units_1
        expect(field_info[:join_info][0][:on_clause]).to be == { ingredients__measuring_unit_id: :measuring_units_1__id }
      end

      it "retrieves the field info and basic join information from a belongs_to as" do
        field_info = alias_dataset.field_information(:measuring_units, :name)

        expect(field_info[:name]).to be == :measuring_units_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 1
        expect(field_info[:join_info][0][:table_name]).to be == :measuring_units
        expect(field_info[:join_info][0][:table_alias]).to be == :measuring_units_1
        expect(field_info[:join_info][0][:on_clause]).to be == { measuring_units_1__id:        :search_aliases__aliased_id,
                                                                 search_aliases__aliased_type: "MeasuringUnit" }
      end
    end

    describe "#has_many" do
      it "retrieves the field info and basic join information from a simple has_many" do
        field_info = mu_dataset.field_information(:ingredients, :name)

        expect(field_info[:name]).to be == :ingredients_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 1
        expect(field_info[:join_info][0][:table_name]).to be == :ingredients
        expect(field_info[:join_info][0][:table_alias]).to be == :ingredients_1
        expect(field_info[:join_info][0][:on_clause]).to be == { ingredients_1__measuring_unit_id: :measuring_units__id }
      end

      it "retrieves the field info and basic join information from a has_and_belongs_to_many join table" do
        field_info = mu_through_dataset.field_information(:larger_measuring_units, :name)

        expect(field_info[:name]).to be == :larger_measuring_units_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 2
        expect(field_info[:join_info][0][:table_name]).to be == :measuring_units
        expect(field_info[:join_info][0][:table_alias]).to be == :larger_measuring_units_1
        expect(field_info[:join_info][0][:on_clause]).to be == { measurement_conversions_2__larger_measuring_unit_id: :larger_measuring_units_1__id }
        expect(field_info[:join_info][1][:table_name]).to be == :measurement_conversions
        expect(field_info[:join_info][1][:table_alias]).to be == :measurement_conversions_2
        expect(field_info[:join_info][1][:on_clause]).to be == { measurement_conversions_2__smaller_measuring_unit_id: :measuring_units__id }
      end

      it "retrieves the field info and basic join information from an as has_many" do
        field_info = mu_dataset.field_information(:search_aliases, :alias)

        expect(field_info[:name]).to be == :search_aliases_1__alias
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 1
        expect(field_info[:join_info][0][:table_name]).to be == :search_aliases
        expect(field_info[:join_info][0][:table_alias]).to be == :search_aliases_1
        expect(field_info[:join_info][0][:on_clause]).to be == { search_aliases_1__aliased_id:   :measuring_units__id,
                                                                 search_aliases_1__aliased_type: "MeasuringUnit" }
      end
    end

    describe "#has_one" do
      it "retrieves the field info and basic join information from a has_one" do
        field_info = has_one_dataset.field_information(:recipes, :name)

        expect(field_info[:name]).to be == :recipes_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 1
        expect(field_info[:join_info][0][:table_name]).to be == :recipes
        expect(field_info[:join_info][0][:table_alias]).to be == :recipes_1
        expect(field_info[:join_info][0][:on_clause]).to be == { recipes_1__recipe_type_id: :recipe_types__id }
      end

      it "retrieves the field info and basic join information from a has_one through" do
        field_info = has_one_through_dataset.field_information(:ingredients, :name)

        expect(field_info[:name]).to be == :ingredients_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 2
        expect(field_info[:join_info][0][:table_name]).to be == :ingredients
        expect(field_info[:join_info][0][:table_alias]).to be == :ingredients_1
        expect(field_info[:join_info][0][:on_clause]).to be == { recipes_2__ingredient_type_id: :ingredients_1__id }
        expect(field_info[:join_info][1][:table_name]).to be == :recipes
        expect(field_info[:join_info][1][:table_alias]).to be == :recipes_2
        expect(field_info[:join_info][1][:on_clause]).to be == { recipes_2__recipe_type_id: :recipe_types__id }
      end
    end

    describe "#has_and_belongs_to_many" do
      it "retrieves the field info and basic join information" do
        field_info = FilterDataset.new(:recipes, FilterParamParser.new(nil)).field_information(:containers, :name)

        expect(field_info[:name]).to be == :containers_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 2
        expect(field_info[:join_info][0][:table_name]).to be == :containers
        expect(field_info[:join_info][0][:table_alias]).to be == :containers_1
        expect(field_info[:join_info][0][:on_clause]).to be == { containers_recipes_2__container_id: :containers_1__id }
        expect(field_info[:join_info][1][:table_name]).to be == :containers_recipes
        expect(field_info[:join_info][1][:table_alias]).to be == :containers_recipes_2
        expect(field_info[:join_info][1][:on_clause]).to be == { containers_recipes_2__recipe_id: :recipes__id }
      end

      it "retrieves the field info and basic join information" do
        field_info = FilterDataset.new(:containers, FilterParamParser.new(nil)).field_information(:recipes, :name)

        expect(field_info[:name]).to be == :recipes_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 2
        expect(field_info[:join_info][0][:table_name]).to be == :recipes
        expect(field_info[:join_info][0][:table_alias]).to be == :recipes_1
        expect(field_info[:join_info][0][:on_clause]).to be == { containers_recipes_2__recipe_id: :recipes_1__id }
        expect(field_info[:join_info][1][:table_name]).to be == :containers_recipes
        expect(field_info[:join_info][1][:table_alias]).to be == :containers_recipes_2
        expect(field_info[:join_info][1][:on_clause]).to be == { containers_recipes_2__container_id: :containers__id }
      end

      it "retrieves the field info and basic join information with a custom table" do
        field_info = mu_dataset.field_information(:larger_measuring_units, :name)

        expect(field_info[:name]).to be == :larger_measuring_units_1__name
        expect(field_info[:type]).to be == :string
        expect(field_info[:join_info].length).to be == 2
        expect(field_info[:join_info][0][:table_name]).to be == :measuring_units
        expect(field_info[:join_info][0][:table_alias]).to be == :larger_measuring_units_1
        expect(field_info[:join_info][0][:on_clause]).to be == { measurement_conversions_2__larger_measuring_unit_id: :larger_measuring_units_1__id }
        expect(field_info[:join_info][1][:table_name]).to be == :measurement_conversions
        expect(field_info[:join_info][1][:table_alias]).to be == :measurement_conversions_2
        expect(field_info[:join_info][1][:on_clause]).to be == { measurement_conversions_2__smaller_measuring_unit_id: :measuring_units__id }
      end
    end

    describe "it deals with errors" do
      it "an ambiguous relationship in a single type of relationship raises an error" do
        expect { mu_dataset.field_information(:measurement_conversions, :name) }.
            to raise_error(FilterDataset::InvalidParseException)
      end

      it "an ambiguous relationship through different relationship types raises an error" do
        expect { has_too_many_dataset.field_information(:measurement_conversions, :name) }.
            to raise_error(FilterDataset::InvalidParseException)
      end

      it "an ambiguous relationship through different relationship types with the proper name works" do
        expect { has_too_many_dataset.field_information(:larger_measurement_conversions, :multiplier) }.
            not_to raise_error
      end

      it "an unknown relationship raises an error" do
        expect { mu_dataset.field_information(:containers, :name) }.
            to raise_error(FilterDataset::InvalidParseException)
      end

      it "an unknown column raises an error" do
        expect { mu_dataset.field_information(:ingredients, :fake_column_name) }.
            to raise_error(FilterDataset::InvalidParseException)
      end

      it "an unknown table raises an error" do
        expect { mu_dataset.field_information(:fake_tables, :fake_column_name) }.
            to raise_error
      end
    end
  end
end