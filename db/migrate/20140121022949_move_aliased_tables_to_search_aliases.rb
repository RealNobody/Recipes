class MoveAliasedTablesToSearchAliases < ActiveRecord::Migration
  class PrepOrder < ActiveRecord::Base
    aliased
  end

  class Recipe < ActiveRecord::Base
    aliased
  end

  class RecipeType < ActiveRecord::Base
    aliased
  end

  def up
    alias_tables = [
        { alias_table: "container_aliases", alias_id: "container_id", aliased_class: "Container" },
        { alias_table: "ingredient_aliases", alias_id: "ingredient_id", aliased_class: "Ingredient" },
        { alias_table: "keyword_aliases", alias_id: "keyword_id", aliased_class: "Keyword" },
        { alias_table: "measurement_aliases", alias_id: "measuring_unit_id", aliased_class: "MeasuringUnit" }
    ]

    alias_tables.each do |alias_table|
      execute <<-SQL
        INSERT INTO
          search_aliases
        (
          alias
          , aliased_id
          , aliased_type
          , created_at
          , updated_at
        )
        SELECT
          #{alias_table[:alias_table]}.alias
          , #{alias_table[:alias_table]}.#{alias_table[:alias_id]}
          , '#{alias_table[:aliased_class]}'
          , #{alias_table[:alias_table]}.created_at
          , #{alias_table[:alias_table]}.updated_at
        FROM
          #{alias_table[:alias_table]}
          LEFT JOIN search_aliases
            ON (#{alias_table[:alias_table]}.alias = search_aliases.alias
               AND search_aliases.aliased_type = '#{alias_table[:aliased_class]}')
        WHERE
          search_aliases.id IS NULL
      SQL
    end

    PrepOrder.all.each do | prep_order |
      prep_order.create_default_aliases
    end

    Recipe.all.each do | recipe |
      recipe.create_default_aliases
    end

    RecipeType.all.each do | recipe_type |
      recipe_type.create_default_aliases
    end

    execute <<-SQL
      UPDATE
        search_aliases
        INNER JOIN search_aliases AS new_alias
          ON (search_aliases.aliased_type = SUBSTR(new_alias.aliased_type, 35)
              AND search_aliases.alias = new_alias.alias
             )
      SET
        search_aliases.aliased_id = new_alias.aliased_id
      WHERE
        SUBSTR(new_alias.aliased_type, 1, 34) = 'MoveAliasedTablesToSearchAliases::'
    SQL

    execute <<-SQL
      DELETE
        new_alias
      FROM
        search_aliases AS new_alias
        INNER JOIN search_aliases
          ON (search_aliases.aliased_type = SUBSTR(new_alias.aliased_type, 35)
              AND search_aliases.alias = new_alias.alias
             )
      WHERE
        SUBSTR(new_alias.aliased_type, 1, 34) = 'MoveAliasedTablesToSearchAliases::'
    SQL

    execute <<-SQL
      UPDATE
        search_aliases
      SET
        aliased_type = SUBSTR(aliased_type, 35)
      WHERE
        SUBSTR(aliased_type, 1, 34) = 'MoveAliasedTablesToSearchAliases::'
    SQL
  end

  def down
    alias_tables = [
        { alias_table: "container_aliases", alias_id: "container_id", aliased_class: "Container" },
        { alias_table: "ingredient_aliases", alias_id: "ingredient_id", aliased_class: "Ingredient" },
        { alias_table: "keyword_aliases", alias_id: "keyword_id", aliased_class: "Keyword" },
        { alias_table: "measurement_aliases", alias_id: "measuring_unit_id", aliased_class: "MeasuringUnit" }
    ]

    alias_tables.each do |alias_table|
      execute <<-SQL
        INSERT INTO
          #{alias_table[:alias_table]}
        (
          alias
          , #{alias_table[:alias_id]}
          , created_at
          , updated_at
        )
        SELECT
          search_aliases.alias
          , search_aliases.aliased_id
          , search_aliases.created_at
          , search_aliases.updated_at
        FROM
          search_aliases
          LEFT JOIN #{alias_table[:alias_table]}
            ON (search_aliases.alias = #{alias_table[:alias_table]}.alias)
        WHERE
          search_aliases.aliased_type = '#{alias_table[:aliased_class]}'
          AND #{alias_table[:alias_table]}.id IS NULL
      SQL

      execute <<-SQL
        UPDATE
          #{alias_table[:alias_table]}
          INNER JOIN search_aliases
            ON (search_aliases.alias = #{alias_table[:alias_table]}.alias)
        SET
          #{alias_table[:alias_table]}.#{alias_table[:alias_id]} = search_aliases.aliased_id
          , #{alias_table[:alias_table]}.created_at = search_aliases.created_at
          , #{alias_table[:alias_table]}.updated_at = search_aliases.updated_at
        WHERE
          search_aliases.aliased_type = '#{alias_table[:aliased_class]}'
      SQL
    end
  end
end