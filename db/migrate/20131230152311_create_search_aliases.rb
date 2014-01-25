class CreateSearchAliases < ActiveRecord::Migration
  def change
    create_table :search_aliases do |t|
      t.string :alias
      t.references :aliased, polymorphic: true

      t.timestamps
    end

    add_index(:search_aliases, [:aliased_type, :alias], unique: true)
  end
end