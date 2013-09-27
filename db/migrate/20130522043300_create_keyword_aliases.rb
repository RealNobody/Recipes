class CreateKeywordAliases < ActiveRecord::Migration
  def change
    create_table :keyword_aliases do |t|
      alias_of :keywords

      t.timestamps
    end
  end
end
