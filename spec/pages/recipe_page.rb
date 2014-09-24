require "pages/item_edit_section"
require "pages/recipe_app_page"
require "pages/search_alias_page"

module RecipePages
  class EditRecipeSection < SitePrism::Section
  end

  class EditSection < SitePrism::Section
    element :recipe_tab, "a[href=\"#recipe\"]"
    element :edit_tab, "a[href=\"#edit\"]"
    element :free_form_tab, "a[href=\"#free-form\"]"

    section :edit_recipe, EditRecipeSection, "#edit-recipe"
  end

  class RecipeShowSection < ItemEditSection
    element :name, "#recipe_name"
    element :meals, "#recipe_meals"
    element :servings, "#recipe_servings"
    element :cooking_instructions, "#recipe_cooking_instructions"
    element :prep_instructions, "#recipe_prep_instructions"
    element :label_instructions, "#recipe_label_instructions"
    element :recipe_type, "#link_recipe_recipe_type_id"
    element :prep_order, "#link_recipe_prep_order_id"
  end

  class RecipeSection < RecipeShowSection
    # element :name, "#recipe_name"
    # element :meals, "#recipe_meals"
    # element :servings, "#recipe_servings"
    # element :cooking_instructions, "#recipe_cooking_instructions"
    # element :prep_instructions, "#recipe_prep_instructions"
    # element :label_instructions, "#recipe_label_instructions"

    # element :recipe_type, "#link_recipe_recipe_type_id"
    element :pick_recipe_type, "#pick_recipe_recipe_type_id"
    section :pick_dialog_recipe_type, PickDialogSection, "#pick-scroll-recipe_type"

    # element :prep_order, "#link_recipe_prep_order_id"
    element :pick_prep_order, "#pick_recipe_prep_order_id"
    section :pick_dialog_prep_order, PickDialogSection, "#pick-scroll-prep_order"
  end

  class RecipeEditPage < RecipeAppPage
    def populate_hash_values(values)
      recipe_tab.click if has_recipe_tab?

      recipe.name.set(values[:name])
      recipe.meals.set(values[:meals])
      recipe.servings.set(values[:servings])
      recipe.cooking_instructions.set(values[:cooking_instructions])
      recipe.prep_instructions.set(values[:prep_instructions])
      recipe.label_instructions.set(values[:label_instructions])

      pick_item(recipe, values, :ingredient, :ingredient_category)
    end

    def validate_hash_values(values)
    end
  end

  class RecipeViewPage < RecipeAppPage
    def populate_hash_values(values)
    end

    def validate_hash_values(values)
      expect(recipe.name.text).to eq(values[:name])
      expect(recipe.meals.text).to eq(values[:meals])
      expect(recipe.servings.text).to eq(values[:servings])
      expect(recipe.cooking_instructions.text).to eq(values[:cooking_instructions])
      expect(recipe.prep_instructions.text).to eq(values[:prep_instructions])
      expect(recipe.label_instructions.text).to eq(values[:label_instructions])

      recipe_type = RecipeType.where(id: values[:recipe_type_id]).first
      expect(recipe.recipe_type.text).to eq(recipe_type.name)

      prep_order = PrepOrder.where(id: values[:prep_order_id]).first
      expect(recipe.prep_order.text).to eq(prep_order.name)
    end
  end

  class RecipeFullPage < RecipeEditPage
    full_page_for Recipe
  end

  class RecipeItemPage < RecipeEditPage
    item_page_for Recipe
  end

  class RecipeScrollingListPage < RecipeAppPage
    scrolling_list_page_for Recipe
  end

  class RecipeSearchAliasChildItemPage < SearchAliasViewPage
    child_item_page_for Recipe, SearchAlias, :search_aliases
  end

  class RecipeSearchAliasChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Recipe, SearchAlias, :search_aliases
  end

  # class RecipeContainerChildItemPage < ContainerViewPage
  #   child_item_page_for Recipe, Container, :containers
  # end

  class RecipeContainerChildScrollingListPage < RecipeAppPage
    child_scrolling_list_page_for Recipe, Container, :containers
  end
end