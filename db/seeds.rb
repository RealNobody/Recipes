# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts("Seeding users...")
User.where(email: "realnobody1@cox.net").first_or_initialize().tap do |admin_user|
  admin_user.password = "Nobody12"
  admin_user.name     = "Real Nobody"
  admin_user.save!()
end

User.where(email: "Guest@guest.com").first_or_initialize().tap do |admin_user|
  admin_user.password = "password"
  admin_user.name     = "Guest@guest.com"
  admin_user.save!()
end


# Recipes seeds

# Measuring Units
puts("Seeding Measuring Units and aliases...")
MeasuringUnit.find_or_initialize("Cup").tap do |unit|
  unit.abbreviation = "C."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("c").save!()
end

MeasuringUnit.find_or_initialize("Teaspoon").tap do |unit|
  unit.abbreviation = "tsp."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("tsp").save!()
end

MeasuringUnit.find_or_initialize("Tablespoon").tap do |unit|
  unit.abbreviation = "Tbs."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("tbs").save!()
end

MeasuringUnit.find_or_initialize("Fluid-Ounce").tap do |unit|
  unit.abbreviation = "fl. oz."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("fl. oz").save!()
  unit.add_alias("fl oz.").save!()
  unit.add_alias("fl oz").save!()
  unit.add_alias("Liquid Ounce").save!()
  unit.add_alias("Liquid Ounces").save!()
  unit.add_alias("lo.").save!()
  unit.add_alias("lo").save!()
end

MeasuringUnit.find_or_initialize("Ounce").tap do |unit|
  unit.abbreviation = "oz."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("oz").save!()
end

MeasuringUnit.find_or_initialize("Pound").tap do |unit|
  unit.abbreviation = "lbs."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("lbs").save!()
  unit.add_alias("lb.").save!()
  unit.add_alias("lb").save!()
end

MeasuringUnit.find_or_initialize("Unit").tap do |unit|
  unit.abbreviation = ""
  unit.can_delete   = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Bunch").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Package").tap do |unit|
  unit.abbreviation = "pkgs."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("pkg.").save!()
  unit.add_alias("pkg").save!()
  unit.add_alias("pkgs").save!()
end

MeasuringUnit.find_or_initialize("Pint").tap do |unit|
  unit.abbreviation = "pt."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("pt").save!()
  unit.add_alias("pts.").save!()
  unit.add_alias("pts").save!()
end

MeasuringUnit.find_or_initialize("Quart").tap do |unit|
  unit.abbreviation = "qt."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("qt").save!()
  unit.add_alias("qts.").save!()
  unit.add_alias("qts").save!()
end

MeasuringUnit.find_or_initialize("Gallon").tap do |unit|
  unit.abbreviation = "gal."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("gal").save!()
  unit.add_alias("gals.").save!()
  unit.add_alias("gals").save!()
end

MeasuringUnit.find_or_initialize("Strip").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Clove").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Loaf").tap do |unit|
  unit.can_delete = false
  unit.save!()

  unit.add_alias("loaves").save!()
end

MeasuringUnit.find_or_initialize("Can").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Jar").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_initialize("Slice").tap do |unit|
  unit.can_delete = false
  unit.save!()

  unit.add_alias("Slices").save!()
end

MeasuringUnit.find_or_initialize("Heaping-Teaspoon").tap do |unit|
  unit.abbreviation = "h tsp."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("h tsp").save!()
  unit.add_alias("heaping tsp").save!()
  unit.add_alias("heaping tsp.").save!()
  unit.add_alias("ht.").save!()
  unit.add_alias("ht").save!()
end

MeasuringUnit.find_or_initialize("Gram").tap do |unit|
  unit.abbreviation = "g."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("g").save!()
end

MeasuringUnit.find_or_initialize("Kilogram").tap do |unit|
  unit.abbreviation = "kg."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("kg").save!()
end

MeasuringUnit.find_or_initialize("Milliliter").tap do |unit|
  unit.abbreviation = "ml."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("ml").save!()
end

MeasuringUnit.find_or_initialize("Liter").tap do |unit|
  unit.abbreviation = "l."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("l").save!()
end

# Code while debugging conversions to clear seeds in between times.

#puts("Removing default seeds")
#
#MeasurementConversion.all.each do | conversion_obj |
#  if (!conversion_obj.larger_measuring_unit.can_delete?() && !conversion_obj.smaller_measuring_unit.can_delete?())
#    conversion_obj.destroy()
#  end
#end

puts("Seed standard conversions")

from_unit = MeasuringUnit.find_or_initialize("Milliliter")
to_unit   = MeasuringUnit.find_or_initialize("Liter")
from_unit.add_conversion(to_unit, 1000)

from_unit = MeasuringUnit.find_or_initialize("Milliliter")
to_unit   = MeasuringUnit.find_or_initialize("Teaspoon")
from_unit.add_conversion(to_unit, 4.92892)

from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
to_unit   = MeasuringUnit.find_or_initialize("Tablespoon")
from_unit.add_conversion(to_unit, 3)

# An approximate conversion to simplify life/conversions...
from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
to_unit   = MeasuringUnit.find_or_initialize("Heaping-Teaspoon")
from_unit.add_conversion(to_unit, 1.5)

from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
to_unit   = MeasuringUnit.find_or_initialize("Fluid-Ounce")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
to_unit   = MeasuringUnit.find_or_initialize("Cup")
from_unit.add_conversion(to_unit, 16)

from_unit = MeasuringUnit.find_or_initialize("Cup")
to_unit   = MeasuringUnit.find_or_initialize("Pint")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Pint")
to_unit   = MeasuringUnit.find_or_initialize("Quart")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Quart")
to_unit   = MeasuringUnit.find_or_initialize("Gallon")
from_unit.add_conversion(to_unit, 4)

from_unit = MeasuringUnit.find_or_initialize("Gram")
to_unit   = MeasuringUnit.find_or_initialize("Kilogram")
from_unit.add_conversion(to_unit, 1000)

from_unit = MeasuringUnit.find_or_initialize("Gram")
to_unit   = MeasuringUnit.find_or_initialize("Ounce")
from_unit.add_conversion(to_unit, 28.3495)

from_unit = MeasuringUnit.find_or_initialize("Ounce")
to_unit   = MeasuringUnit.find_or_initialize("Pound")
from_unit.add_conversion(to_unit, 16)

puts("Seeding Ingredient Categories...")

IngredientCategory.find_or_initialize_by_name("Recipe").tap do |ingredient_category|
  ingredient_category.name  = "Recipe"
  ingredient_category.order = 0

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Unknown/Other").tap do |ingredient_category|
  ingredient_category.name  = "Unknown/Other"
  ingredient_category.order = 1

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Ethnic Foods").tap do |ingredient_category|
  ingredient_category.name  = "Ethnic Foods"
  ingredient_category.order = 2

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Salad Fixings").tap do |ingredient_category|
  ingredient_category.name  = "Salad Fixings"
  ingredient_category.order = 3

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Condiments").tap do |ingredient_category|
  ingredient_category.name  = "Condiments"
  ingredient_category.order = 4

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Canned Soup").tap do |ingredient_category|
  ingredient_category.name  = "Canned Soup"
  ingredient_category.order = 5

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Baking Goods").tap do |ingredient_category|
  ingredient_category.name  = "Baking Goods"
  ingredient_category.order = 6

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Spices").tap do |ingredient_category|
  ingredient_category.name  = "Spices"
  ingredient_category.order = 7

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Canned Tomato Products").tap do |ingredient_category|
  ingredient_category.name  = "Canned Tomato Products"
  ingredient_category.order = 8

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Canned Vegetables").tap do |ingredient_category|
  ingredient_category.name  = "Canned Vegetables"
  ingredient_category.order = 9

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Canned Fruit").tap do |ingredient_category|
  ingredient_category.name  = "Canned Fruit"
  ingredient_category.order = 10

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Pasta").tap do |ingredient_category|
  ingredient_category.name  = "Pasta"
  ingredient_category.order = 11

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Rice/Dry Goods").tap do |ingredient_category|
  ingredient_category.name  = "Rice/Dry Goods"
  ingredient_category.order = 12

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Candy").tap do |ingredient_category|
  ingredient_category.name  = "Candy"
  ingredient_category.order = 13

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Juices").tap do |ingredient_category|
  ingredient_category.name  = "Juices"
  ingredient_category.order = 14

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Cereal").tap do |ingredient_category|
  ingredient_category.name  = "Cereal"
  ingredient_category.order = 15

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Crackers/Cookies").tap do |ingredient_category|
  ingredient_category.name  = "Crackers/Cookies"
  ingredient_category.order = 16

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Fruits/Vegetables").tap do |ingredient_category|
  ingredient_category.name  = "Fruits/Vegetables"
  ingredient_category.order = 17

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Frozen/Refrigerated items").tap do |ingredient_category|
  ingredient_category.name  = "Frozen/Refrigerated items"
  ingredient_category.order = 18

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Frozen Vegetables").tap do |ingredient_category|
  ingredient_category.name  = "Frozen Vegetables"
  ingredient_category.order = 19

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Dairy").tap do |ingredient_category|
  ingredient_category.name  = "Dairy"
  ingredient_category.order = 20

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Bread").tap do |ingredient_category|
  ingredient_category.name  = "Bread"
  ingredient_category.order = 21

  ingredient_category.save!()
end

IngredientCategory.find_or_initialize_by_name("Meat").tap do |ingredient_category|
  ingredient_category.name  = "Meat"
  ingredient_category.order = 22

  ingredient_category.save!()
end

puts("Finished Seeding.")