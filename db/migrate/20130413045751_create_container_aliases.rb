class CreateContainerAliases < ActiveRecord::Migration
  def change
    create_table :container_aliases do |t|
      t.alias_of(:containers)

      t.timestamps
    end

    add_alias_index :container_aliases, :containers

    add_index :prep_orders, [:order, :name]

    remove_index :measuring_units, column: :search_name
    remove_column :measuring_units, :search_name
  end
end
