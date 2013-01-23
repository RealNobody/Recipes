class UpdateMeasuringUnitAbbreviationName < ActiveRecord::Migration
  def up
    rename_column :measuring_units, :abreviation, :abbreviation
  end

  def down
    rename_column :measuring_units, :abbreviation, :abreviation
  end
end