class CreateIngredientAliases < ActiveRecord::Migration
  def change
    create_table :ingredient_aliases do |t|
      t.alias_of(:ingredients)

      t.timestamps
    end

    add_alias_index(:ingredient_aliases, :ingredients)

    add_index :ingredient_categories, [:order, :name]
  end
end
