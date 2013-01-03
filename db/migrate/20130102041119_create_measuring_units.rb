class CreateMeasuringUnits < ActiveRecord::Migration
  def change
    create_table :measuring_units do |t|
      t.string :name
      t.string :abreviation
      t.string :search_name

      t.timestamps
    end

    add_index :measuring_units, [ :search_name ], unique: { case_sensitive: false }
  end
end