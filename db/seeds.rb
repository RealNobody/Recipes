# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.where(email: "RealNobody1@cox.net").first_or_initialize().tap do | admin_user |
  admin_user.password = "Nobody12"
  admin_user.name = "Real Nobody"
  admin_user.save()
end