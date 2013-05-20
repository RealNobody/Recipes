class CreatePrepOrders < ActiveRecord::Migration
  def change
    create_table :prep_orders do |t|
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
