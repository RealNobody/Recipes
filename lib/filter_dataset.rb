require "filter_param_parser"

class FilterDataset
  # This class takes as an input either a string or a FilterParamParser.
  # If it receives a string, it will create a FilterParamParser and pass the
  # string into it to parse the string.
  #
  # Once the string has been parsed into a set of query operations and values
  # the dataset will take that information and re-structure/re-form the data
  # into a similar, but slightly different structure for building a query
  # to fetch the data.
  #
  # The new structure is a hash structured as follows:
  #   {
  #     where_clause:   { <where_clause_hash> },
  #     join_clause:    { <join_clause_hash }
  #   }
  #
  #   where_clause_hash:  {
  #                         type:   <clause_type>,
  #                         clause: <string>
  #                         data:   {key: value(, key: value...)}
  #                       }
  #
  #   clause:             This depends on what database interface you are using.
  #                       If using Active Record, this will be a string which will be used
  #                       to build a query string for a where clause.
  #                       This string will contain placeholder values like: :key
  #                       The values will be in the data hash with the same key values.
  #
  #                       If using Sequel, the clause will be a sql_exp which can be
  #                       combined with other clauses to creat the final where clause.
  #
  #     <clause_type>:    :and
  #                       :or
  #                       :"(".to_sym
  #                       :!
  #                       :"!=".to_sym
  #                       :=
  #                       :<
  #                       :>
  #                       :<=
  #                       :>=
  #                       :like
  #                       :custom
  #
  #     <data>:
  #                       This depends on the <clause_type>
  #                         :and
  #                         :or
  #                         :"(".to_sym
  #                         :!
  #                           The data objects will be <where_clause_hash> objects  Each item will have ()
  #                           around it.
  #
  #                         :"!=".to_sym
  #                         :=
  #                         :<
  #                         :>
  #                         :<=
  #                         :>=
  #                         :like
  #                           The values to be used.  The values will be supplied by the data hash.
  #
  #
  # join_clause:          {
  #                         table:  :<table_name>
  #                         type:   <join_type>
  #                         clause: <on_clause>
  #                         alias:  :<alias_name>
  #                       }
  #
  #     <on_clause>       { <table_name>__<column>: :<alias_table_name>__<column> }
  #
  #     <join_type>       :left
  #                       :right
  #                       :inner
  #
  #
  #
  # This system was first built using Sequel, but has since been expanded.  There are some conventions
  # which are borrowed from Sequel.
  #
  #
  # Filtering the dataset works in two phases.
  #
  # The first phase processes the filter parameters and processes the inputs into the structure needed
  # to build the where clauses.
  #
  # The second phase actually builds the scoped object.
  #
  # To transform the parsed information into the format needed for building the where clauses, we
  # need to know about the fields.

  class InvalidParseException < Exception
  end

  def initialize(model_type, filter_params)
    if filter_params.is_a?(FilterParamParser)
      @filter_params = filter_params
    else
      @filter_params = FilterParamParser.new(filter_params)
    end

    @model = model_type.to_s.classify.constantize

    transform_params
  end

  def field_information(table_name, field_name)
    @table_columns ||= {}
    @alias_count   ||= 0

    table_name     = @model.table_name.to_sym unless table_name

    unless @table_columns[table_name]
      if Object.const_defined?(table_name.to_s.classify, false)
        table_object               = table_name.to_s.classify.constantize
        @table_columns[table_name] = table_object.columns.reduce({}) do |hash, column|
          hash[column.name.to_sym] = column
          hash
        end
      end
    end

    field_info = {}

    if table_name != @model.name.tableize.to_sym
      [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many].each do |relationship|
        possible_relations = @model.reflect_on_all_associations(relationship).select do |relation_info|
          relation_info.name == table_name ||
              relation_info.name.to_s.pluralize.to_sym == table_name ||
              relation_info.options[:polymorphic] ||
              relation_info.klass.table_name.to_sym == table_name ||
              relation_info.klass.name.tableize.to_sym == table_name
        end

        if possible_relations.length > 1
          raise InvalidParseException.new("could not decide which relation to use for #{table_name}")
        end

        if possible_relations.length == 1
          if field_info[:join_info]
            raise InvalidParseException.new("too many possible relationships for #{table_name}__#{field_name}")
          end

          relation_info = possible_relations[0]

          unless @table_columns[table_name]
            @table_columns[table_name] = relation_info.klass.columns.reduce({}) do |hash, column|
              hash[column.name.to_sym] = column
              hash
            end
          end

          field_info[:join_info] = []
          @alias_count           += 1
          join_alias             = "#{table_name}_#{@alias_count}".to_sym
          field_info[:join_info] << { table_alias: join_alias }

          if relation_info.options[:polymorphic]
            field_info[:join_info][0][:table_name] = table_name
          else
            field_info[:join_info][0][:table_name] = relation_info.klass.table_name.to_sym
          end

          field_info[:name] = "#{join_alias}__#{field_name}".to_sym

          case relation_info.macro
            when :has_and_belongs_to_many
              @alias_count  += 1
              through_table = relation_info.options[:join_table]
              unless through_table
                if relation_info.active_record.name < relation_info.klass.name
                  through_table = "#{relation_info.active_record.table_name}_#{relation_info.klass.table_name}".
                      to_sym
                else
                  through_table = "#{relation_info.klass.table_name}_#{relation_info.active_record.table_name}".
                      to_sym
                end
              end
              through_alias      = "#{through_table}_#{@alias_count}".to_sym
              through_field_name = relation_info.options[:foreign_key]
              through_field_name ||= "#{relation_info.active_record.table_name.singularize}_id".to_sym

              field_info[:join_info] << {
                  table_name:  through_table,
                  table_alias: through_alias,
                  on_clause:   { "#{through_alias}__#{through_field_name}".to_sym =>
                                     "#{@model.table_name}__id".to_sym }
              }

            source_table      = relation_info.klass.table_name.to_sym
            source_field_name = relation_info.options[:association_foreign_key]
            source_field_name ||= "#{source_table.to_s.singularize}_id".to_sym

            field_info[:join_info][0][:on_clause] = { "#{through_alias}__#{source_field_name}".to_sym =>
                                                          "#{join_alias}__id".to_sym }

            when :belongs_to
              if relation_info.options[:polymorphic]
                field_info[:join_info][0][:on_clause] = { "#{join_alias}__id".to_sym                     =>
                                                              "#{@model.table_name}__#{relation_info.name}_id".to_sym,
                                                          "#{@model.table_name}__#{relation_info.name}_type".to_sym =>
                                                              table_name.to_s.classify }
              else
                belongs_to_field_name = relation_info.options[:foreign_key]
                belongs_to_field_name ||= "#{table_name.to_s.singularize}_id"

                field_info[:join_info][0][:on_clause] = { "#{@model.table_name}__#{belongs_to_field_name}".to_sym => "#{join_alias}__id".to_sym }
              end

            else
              if relation_info.options[:as]
                field_info[:join_info][0][:on_clause] = { "#{join_alias}__#{relation_info.options[:as]}_id".to_sym   =>
                                                              "#{@model.table_name}__id".to_sym,
                                                          "#{join_alias}__#{relation_info.options[:as]}_type".to_sym =>
                                                              relation_info.active_record.name }
              elsif relation_info.options[:through]
                @alias_count       += 1
                through_table      = relation_info.through_reflection.klass.table_name.to_sym
                through_alias      = "#{through_table}_#{@alias_count}".to_sym
                through_field_name = relation_info.through_reflection.options[:foreign_key]
                through_field_name ||= "#{@model.table_name.to_s.singularize}_id".to_sym

                field_info[:join_info] << {
                    table_name:  through_table,
                    table_alias: through_alias,
                    on_clause:   { "#{through_alias}__#{through_field_name}".to_sym =>
                                       "#{@model.table_name}__id".to_sym }
                }

                source_table      = relation_info.source_reflection.klass.table_name.to_sym
                source_field_name = relation_info.source_reflection.options[:foreign_key]
                source_field_name ||= "#{source_table.to_s.singularize}__id".to_sym

                field_info[:join_info][0][:on_clause] = { "#{through_alias}__#{source_field_name}".to_sym =>
                                                              "#{join_alias}__id".to_sym }
              else
                join_field_name                       = relation_info.options[:foreign_key] || "#{@model.table_name.singularize}_id"
                field_info[:join_info][0][:on_clause] = { "#{join_alias}__#{join_field_name}".to_sym => "#{@model.table_name}__id".to_sym }
              end
          end
        end
      end

      unless field_info[:join_info]
        raise InvalidParseException.new("could not determine related table information for #{table_name}__#{field_name}")
      end
    end

    unless @table_columns[table_name][field_name]
      raise InvalidParseException.new("could not determine column information for #{table_name}.#{field_name}")
    end

    field_info[:name] = "#{table_name}__#{field_name}".to_sym unless field_info[:name]
    field_info[:type] = @table_columns[table_name][field_name].type unless field_info[:type]

    field_info
  end

  def split_field(full_field_name)
    full_field_name          = full_field_name.to_s
    table_field, field_alias = full_field_name.split("___")
    table_name, field_name   = table_field.split("__")

    unless field_name
      field_name = table_name
      table_name = nil
    end

    table_name  = table_name.to_sym if table_name
    field_name  = field_name.to_sym if field_name
    field_alias = field_alias.to_sym if field_alias

    [table_name, field_name, field_alias]
  end

  private
  def transform_params
    @transformed_params = transform_field(@filter_params.parsed_fields) unless @filter_params.parsed_fields.empty?
  end

  def transform_field(parsed_field)
    case parsed_field.type
      when :not_filter, :group
        transform_group(parsed_field.type, parsed_field)

      when
      transform_token(parsed_field.type, parsed_field)

      when :token,
          :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym,
          :[], "~[]".to_sym, :"![]".to_sym, "!~[]".to_sym
        transform_comparison(parsed_field.type, parsed_field)

      when :&, :|
        transform_boolean(parsed_field.type, parsed_field)
    end
  end

  def transform_group(type, parsed_field)
    { type: type, filter_expression: transform_field(parsed_field[:filter_expression]) }
  end

  def transform_boolean(type, parsed_field)
    { type:               type,
      filter_expressions: parsed_field[:filter_expressions].map { |filter_expression| transform_field(filter_expression) }
    }
  end

  def transform_comparison(type, parsed_field)
    table_name, field_name, field_alias = split_field(parsed_field[:token])
    field_info                          = field_information(table_name, field_name)
  end
end