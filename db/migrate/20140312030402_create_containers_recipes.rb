class CreateContainersRecipes < ActiveRecord::Migration
  def change
    create_table :containers_recipes, id: false do |t|
      t.integer :container_id
      t.integer :recipe_id
    end

    add_index(:containers_recipes, [:recipe_id, :container_id], unique: true)
    add_index(:containers_recipes, :container_id)
    add_index(:containers_recipes, :recipe_id)
  end
end