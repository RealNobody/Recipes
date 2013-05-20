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

MeasuringUnit.find_or_initialize("Slices").tap do |unit|
  unit.can_delete = false
  unit.save!()

  # for some reason, I cannot create a custom inflector for slice <=> slices
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