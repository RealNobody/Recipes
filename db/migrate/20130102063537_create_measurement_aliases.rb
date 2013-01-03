class CreateMeasurementAliases < ActiveRecord::Migration
  def change
    create_table :measurement_aliases do |t|
      t.string  :alias
      t.integer :measuring_unit_id

      t.timestamps
    end

    add_index :measurement_aliases, [ :alias ], unique: true
    add_index :measurement_aliases, [ :measuring_unit_id ]
  end
end