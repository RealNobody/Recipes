class Object
  def alias_metaclass
    class << self;
      self
    end
  end
end

# This file creates the functions needed to alias a table through another table.
# The table structures are:
#
#  def change
#    create_table :<aliased_table_pleural> do |t|
#      t.string :<aliased_field>
#      t.string :<aliased_field>
#      t.string :<aliased_field>
#      ...
#
#      ... other field definitions...
#
#      t.timestamps
#    end
#
#    create_table :<aliased_table>_aliases do |t|
#      alias_of :<aliased_table_pleural>
#
#      t.timestamps
#    end
#
#    add_alias_index :<aliased_table>_aliases, :<aliased_table_pleural>
#  end
#
# The models are:
#  class <AliasedTable> < ActiveRecord::Base
#    aliased_by :<aliased_table>_aliases[, options...]
#
#    ... rest of the model ...
#  end
#
#  class <AliasedTable>Alias < ActiveRecord::Base
#    aliases :<aliased_table>[, options...]
#  end
#
#
#
# The aliasing functions which are created are mostly contained within the aliased table model.
# The alias table is mostly utilitarian and is meant as a helper for finding an item in the
# primary table.
#
# The functions other than validation which are most likely to be of use are:
#
# <AliasedTable>.find_or_initialize
#   The primary purpose of this function is to simplify seeding.  This function will find
#   an existing item by name, or if it cannot be found, will initialize the object with
#   the searched keyword.  The initialization is done by filling in the first item in the
#   default_alias_fields option.
#
# aliased_table_instance.add_alias
#   This function simply adds an alias to the list of aliases for that object.  The new alias is
#   initialized but not saved to disk.
#
# <AliasedTable>.search_alias
#   This function does a non-exact match search of the alias table for any objects who have an alias
#   which might partially match the passed in search value.
#
#   The returned values are sorted in a best guess priority order.

module ActiveRecord
  module Associations # :nodoc:
    module ClassMethods
      def aliased(*arguments)
        # option - alias_fields: [ :name ]
        # option - pleural_alias_fields: [ :name ]
        # option - index_sort: -> { order(initialize_field)}
        # option - allow_blank_aliases: false
        # option - allow_delete_defaults: false

        options = arguments.extract_options!

        alias_fields          = Array.wrap(options[:alias_fields] || :name)
        pleural_alias_fields  = Array.wrap(options[:pleural_alias_fields] || :name)
        index_sort_scope      = options[:index_sort] || -> { order(self.initialize_field) }
        allow_blank_aliases   = !!options[:allow_blank_aliases]
        allow_delete_defaults = options[:allow_delete_defaults].nil? ? true : options[:allow_delete_defaults]
        aliased_class         = self
        aliased_table         = aliased_class.name.tableize

        has_many :search_aliases, dependent: :delete_all, as: :aliased

        after_save :create_default_aliases

        scope :index_sort, index_sort_scope

        @alias_fields = @alias_fields.nil? ? alias_fields.clone : @alias_fields
        @pleural_alias_fields = @pleural_alias_fields.nil? ? pleural_alias_fields.clone : @pleural_alias_fields
        @allow_delete_defaults = @allow_delete_defaults.nil? ? allow_delete_defaults : @allow_delete_defaults
        @allow_blank_aliases = @allow_blank_aliases.nil? ? allow_blank_aliases : @allow_blank_aliases

        validate do
          # alias_name = alias and id is not null
          # alias_name = alias and id != id
          (Array.wrap(self.class.pleural_aliased_fields) | Array.wrap(self.class.aliased_fields)).each do |alias_field|
            find_alias = self.class.find_by_alias(self[alias_field])

            unless (find_alias == nil || find_alias.id == self.id)
              errors.add(:name, I18n.t("activerecord.#{self.class.name.underscore}.error.already_exists",
                                       name: find_alias[alias_field]))
            end
          end
        end

        SearchAlias.class_eval do
          scope "#{aliased_class.name.underscore}_index_sort".to_sym, -> { joins("LEFT JOIN `#{aliased_table}` ON (`#{aliased_table}`.`id` = `search_aliases`.`aliased_id`)").
              where(aliased_type: aliased_class.name).
              order("#{aliased_class.name.tableize}.#{aliased_class.initialize_field}, search_aliases.alias") }
        end

        define_method :list_name do
          list_name_value = I18n.t("activerecord.#{self.class.name.underscore}.list_name",
                                   self.class.name.underscore.to_sym => self.send(self.class.initialize_field),
                                   default:                          "")

          if list_name_value.blank?
            list_name_value = self.send(self.class.initialize_field)
          end

          list_name_value
        end

        define_method :add_alias do |alias_name|
          alias_name = alias_name.downcase()
          found_unit = self.class.find_by_alias(alias_name)

          if (found_unit != nil && found_unit.id != self.id)
            nil
          else
            alias_list = (self.search_aliases).select do |alias_item|
              alias_item.alias == alias_name
            end

            if (alias_list == nil || alias_list.length == 0)
              self.search_aliases.build(alias: alias_name)
            else
              alias_list[0]
            end
          end
        end

        alias_metaclass.instance_eval do
          define_method :aliased? do
            true
          end

          define_method :allow_blank_aliases do
            @allow_blank_aliases
          end

          define_method :allow_delete_defaults do
            @allow_delete_defaults
          end

          define_method :initialize_field do
            if @alias_fields && @alias_fields.length > 0
              initialize_field_return ||= @alias_fields[0]
            end
            if @pleural_alias_fields && @pleural_alias_fields.length > 0
              initialize_field_return ||= @pleural_alias_fields[0]
            end

            initialize_field_return.to_sym
          end

          # This is a helper function to find an item by an alias.
          define_method :find_or_initialize do |alias_name|
            found_unit = self.find_by_alias(alias_name)
            unless found_unit
              initialize_field = self.initialize_field

              if (initialize_field)
                new_args ={ initialize_field => alias_name }
              end

              found_unit = self.new(new_args)
            end

            found_unit
          end

          define_method :aliased_fields do
            @alias_fields.clone
          end

          define_method :pleural_aliased_fields do
            @pleural_alias_fields.clone
          end

          # This is a helper function to find an item by an alias.
          define_method :find_by_alias do |alias_name|
            unless alias_name == nil
              find_alias = SearchAlias.where(alias: "#{alias_name.downcase}").where(aliased_type: self.name).first()
            end
            unless find_alias == nil
              self.find(find_alias.aliased_id)
            end
          end

          # This is a helper function to find items by alias with a loose match.
          #
          # See #SearchAlias.search_alias for details on the parameters.
          define_method :search_alias do |search_string, options = {}|
            search_type_table = options[:search_type_table] || self.name.tableize
            search_type       = options[:search_type] || self.name
            search_class      = options[:search_class] || self

            options[:search_type]       = search_type
            options[:search_type_table] = search_type_table

            SearchAlias.search_alias_full(search_string, search_class, options)
          end
        end

        define_method :is_default_alias? do |test_alias|
          test_alias = test_alias.downcase()

          if (self.class.instance_variable_get("@alias_fields"))
            self.class.instance_variable_get("@alias_fields").each do |alias_field|
              if (self[alias_field] && self[alias_field].singularize.downcase == test_alias)
                return true
              end
            end
          end

          if (self.class.instance_variable_get("@pleural_alias_fields"))
            self.class.instance_variable_get("@pleural_alias_fields").each do |alias_field|
              if (self[alias_field] && self[alias_field].pluralize.downcase == test_alias)
                return true
              end
            end
          end

          false
        end

        #protected
        define_method :create_default_aliases do
          # I want all measuring units to have their own name and abbreviation as aliases.
          if (self.class.instance_variable_get("@alias_fields"))
            self.class.instance_variable_get("@alias_fields").each do |alias_field|
              if (self[alias_field])
                self.add_alias(self[alias_field].singularize).save!
              end
            end
          end

          if (self.class.instance_variable_get("@pleural_alias_fields"))
            self.class.instance_variable_get("@pleural_alias_fields").each do |alias_field|
              if (self[alias_field])
                self.add_alias(self[alias_field].pluralize).save!
              end
            end
          end
        end

        SearchAlias.add_aliased_table(self)
      end
    end
  end

  module ConnectionAdapters #:nodoc:
    module SchemaStatements
      def add_alias_index(table_name, alias_of_table)
        #add_index table_name, [:alias], unique: true
        #add_index table_name, [(alias_of_table.to_s.singularize + "_id").to_sym]
      end
    end

    class TableDefinition
      def alias_of(alias_of_table)
        #self.integer (alias_of_table.to_s.singularize + "_id").to_sym
        #self.string :alias
      end
    end
  end
end