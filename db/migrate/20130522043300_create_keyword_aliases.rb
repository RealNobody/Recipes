class CreateKeywordAliases < ActiveRecord::Migration
  def change
    create_table :keyword_aliases do |t|
      t.string :alias
      t.integer :keyword_id

      t.timestamps
    end
  end
end
