class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.string :name
      t.integer :measuring_unit_id
      t.integer :ingredient_category_id
      t.text :prep_instructions
      t.text :day_before_prep_instructions

      t.timestamps
    end
  end
end