class CreateMeasurementAliases < ActiveRecord::Migration
  def change
    create_table :measurement_aliases do |t|
      t.alias_of(:measuring_units)

      t.timestamps
    end

    add_index :measurement_aliases, [ :alias ], unique: true
    add_index :measurement_aliases, [ :measuring_unit_id ]
  end
end