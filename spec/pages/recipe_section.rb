require "pages/item_edit_section"

class EditRecipeSection < SitePrism::Section
  element :name, "#recipe_name"
  element :meals, "#recipe_meals"
  element :servings, "#recipe_servings"
  element :cooking_instructions, "#recipe_cooking_instructions"
  element :prep_instructions, "#recipe_prep_instructions"
  element :label_instructions, "#recipe_label_instructions"

  element :recipe_type, "#link_recipe_recipe_type_id"
  element :pick_recipe_type, "#pick_recipe_recipe_type_id"
  section :pick_dialog_recipe_type, PickDialogSection, "#pick-scroll-recipe_type"

  element :prep_order, "#link_recipe_prep_order_id"
  element :pick_prep_order, "#pick_recipe_prep_order_id"
  section :pick_dialog_prep_order, PickDialogSection, "#pick-scroll-prep_order"
end

class EditSection < SitePrism::Section
  element :recipe_tab, "a[href=\"#recipe\"]"
  element :edit_tab, "a[href=\"#edit\"]"
  element :free_form_tab, "a[href=\"#free-form\"]"

  section :edit_recipe, EditRecipeSection, "#edit-recipe"
end

class RecipeSection < ItemEditSection
  def populate_hash_values(values)
    edit_tab.click

    edit_recipe.name.set(values[:name])
    edit_recipe.meals.set(values[:meals])
    edit_recipe.servings.set(values[:servings])
    edit_recipe.cooking_instructions.set(values[:cooking_instructions])
    edit_recipe.prep_instructions.set(values[:prep_instructions])
    edit_recipe.label_instructions.set(values[:label_instructions])

    pick_item(self, values, :ingredient, :ingredient_category)
  end
end