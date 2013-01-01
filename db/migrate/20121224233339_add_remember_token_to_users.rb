class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password

    add_index :users, :email, unique: { case_sensitive: false }
    add_index :users, :name, unique: { case_sensitive: false }
  end
end
