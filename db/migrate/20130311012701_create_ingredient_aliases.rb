class CreateIngredientAliases < ActiveRecord::Migration
  def change
    create_table :ingredient_aliases do |t|
      t.alias_of(:ingredients)

      t.timestamps
    end

    add_index :ingredient_aliases, [:alias], unique: true
    add_index :ingredient_aliases, [:ingredient_id]

    add_index :ingredient_categories, [:order, :name]
  end
end
