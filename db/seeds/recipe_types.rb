puts("Seeding Recipe Types...")

RecipeType.find_or_initialize_by(name: "Beef").tap do |recipe_type|
  recipe_type.name  = "Beef"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Chicken").tap do |recipe_type|
  recipe_type.name  = "Chicken"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Fish").tap do |recipe_type|
  recipe_type.name  = "Fish"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Ham").tap do |recipe_type|
  recipe_type.name  = "Ham"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Vegetarian").tap do |recipe_type|
  recipe_type.name  = "Vegetarian"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Other").tap do |recipe_type|
  recipe_type.name  = "Other"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Ingredient").tap do |recipe_type|
  recipe_type.name  = "Ingredient"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Desert").tap do |recipe_type|
  recipe_type.name  = "Desert"

  recipe_type.save!()
end

RecipeType.find_or_initialize_by(name: "Side-Dish").tap do |recipe_type|
  recipe_type.name  = "Side-Dish"

  recipe_type.save!()
end