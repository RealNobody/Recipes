puts("Seeding Recipe Types...")

RecipeType.find_or_initialize_by_name("Beef").tap do |recipe_type|
  recipe_type.name  = "Beef"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Chicken").tap do |recipe_type|
  recipe_type.name  = "Chicken"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Fish").tap do |recipe_type|
  recipe_type.name  = "Fish"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Ham").tap do |recipe_type|
  recipe_type.name  = "Ham"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Vegetarian").tap do |recipe_type|
  recipe_type.name  = "Vegetarian"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Other").tap do |recipe_type|
  recipe_type.name  = "Other"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Ingredient").tap do |recipe_type|
  recipe_type.name  = "Ingredient"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Desert").tap do |recipe_type|
  recipe_type.name  = "Desert"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by_name("Side-Dish").tap do |recipe_type|
  recipe_type.name  = "Side-Dish"

  recipe_type.save!()
end