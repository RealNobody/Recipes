# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts("Seeding users...")
User.where(email: "realnobody1@cox.net").first_or_initialize().tap do |admin_user|
  admin_user.password = "Nobody"
  admin_user.name     = "Real Nobody"
  admin_user.save!()
end

User.where(email: "guest@guest.com").first_or_initialize().tap do |admin_user|
  admin_user.password = "password"
  admin_user.name     = "guest@guest.com"
  admin_user.save!()
end

# Recipes seeds
require File.expand_path("db/seeds/measuring_units")
require File.expand_path("db/seeds/measurement_conversions")
require File.expand_path("db/seeds/ingredient_categories")
require File.expand_path("db/seeds/recipe_types")
require File.expand_path("db/seeds/containers")

puts("Finished Seeding.")