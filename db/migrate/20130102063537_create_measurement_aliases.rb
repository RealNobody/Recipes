class CreateMeasurementAliases < ActiveRecord::Migration
  def change
    create_table :measurement_aliases do |t|
      t.alias_of(:measuring_units)

      t.timestamps
    end

    add_alias_index(:measurement_aliases, :measuring_units)
  end
end