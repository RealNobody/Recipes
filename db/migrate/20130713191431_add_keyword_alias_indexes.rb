class AddKeywordAliasIndexes < ActiveRecord::Migration
  def up
    add_alias_index :keyword_aliases, :keywords
  end

  def down
  end
end
