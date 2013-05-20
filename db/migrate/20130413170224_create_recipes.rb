class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.integer :recipe_type_id
      t.integer :servings
      t.integer :meals
      t.string :label_instructions
      t.integer :prep_order_id
      t.text :prep_instructions
      t.text :cooking_instructions

      t.timestamps
    end
  end
end
