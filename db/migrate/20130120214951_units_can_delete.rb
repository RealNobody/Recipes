class UnitsCanDelete < ActiveRecord::Migration
  def up
    add_column :measuring_units, :can_delete, :boolean
  end

  def down
    remove_column :measuring_units, :can_delete
  end
end