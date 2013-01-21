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


# Recipes seeds

# Measuring Units
puts("Seeding Measuring Units and aliases...")
MeasuringUnit.find_or_intialize("Cup").tap do |unit|
  unit.abbreviation = "C."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("c").save!()
end

MeasuringUnit.find_or_intialize("Teaspoon").tap do |unit|
  unit.abbreviation = "tsp."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("tsp").save!()
end

MeasuringUnit.find_or_intialize("Tablespoon").tap do |unit|
  unit.abbreviation = "Tbs."
  unit.can_delete   = false
  unit.save!()

  unit.add_alias("tbs").save!()
end

MeasuringUnit.find_or_intialize("Fluid-Ounce").tap do |unit|
  unit.abbreviation = "fl. oz."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("fl. oz").save!()
  unit.add_alias("fl oz.").save!()
  unit.add_alias("fl oz").save!()
  unit.add_alias("Liquid Ounce").save!()
  unit.add_alias("Liquid Ounces").save!()
  unit.add_alias("lo.").save!()
  unit.add_alias("lo").save!()
end

MeasuringUnit.find_or_intialize("Ounce").tap do |unit|
  unit.abbreviation = "oz."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("oz").save!()
end

MeasuringUnit.find_or_intialize("Pound").tap do |unit|
  unit.abbreviation = "lbs."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("lbs").save!()
  unit.add_alias("lb.").save!()
  unit.add_alias("lb").save!()
end

MeasuringUnit.find_or_intialize("Unit").tap do |unit|
  unit.abbreviation = ""
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Bunch").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Package").tap do |unit|
  unit.abbreviation = "pkgs."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("pkg.").save!()
  unit.add_alias("pkg").save!()
  unit.add_alias("pkgs").save!()
end

MeasuringUnit.find_or_intialize("Pint").tap do |unit|
  unit.abbreviation = "pt."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("pt").save!()
  unit.add_alias("pts.").save!()
  unit.add_alias("pts").save!()
end

MeasuringUnit.find_or_intialize("Quart").tap do |unit|
  unit.abbreviation = "qt."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("qt").save!()
  unit.add_alias("qts.").save!()
  unit.add_alias("qts").save!()
end

MeasuringUnit.find_or_intialize("Gallon").tap do |unit|
  unit.abbreviation = "gal."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("gal").save!()
  unit.add_alias("gals.").save!()
  unit.add_alias("gals").save!()
end

MeasuringUnit.find_or_intialize("Strip").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Clove").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Loaf").tap do |unit|
  unit.can_delete = false
  unit.save!()

  unit.add_alias("loaves").save!()
end

MeasuringUnit.find_or_intialize("Can").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Jar").tap do |unit|
  unit.can_delete = false
  unit.save!()
end

MeasuringUnit.find_or_intialize("Slice").tap do |unit|
  unit.can_delete = false
  unit.save!()

  unit.add_alias("Slices").save!()
end

MeasuringUnit.find_or_intialize("Heaping-Teaspoon").tap do |unit|
  unit.abbreviation = "h tsp."
  unit.can_delete = false
  unit.save!()

  unit.add_alias("h tsp").save!()
  unit.add_alias("heaping tsp").save!()
  unit.add_alias("heaping tsp.").save!()
  unit.add_alias("ht.").save!()
  unit.add_alias("ht").save!()
end

puts("Finished Seeding.")