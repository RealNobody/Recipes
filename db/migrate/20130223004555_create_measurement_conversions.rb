class CreateMeasurementConversions < ActiveRecord::Migration
  def change
    create_table :measurement_conversions do |t|
      t.integer :smaller_measuring_unit_id
      t.integer :larger_measuring_unit_id
      t.float :multiplier

      t.timestamps
    end

    add_index :measurement_conversions, [:smaller_measuring_unit_id, :larger_measuring_unit_id],
              unique: true, name: "conversion_units_index"
  end
end
