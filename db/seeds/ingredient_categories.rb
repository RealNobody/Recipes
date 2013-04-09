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