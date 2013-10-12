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
      def aliased_by(alias_table, options = {})
        # option - default_alias_fields: [ :name ]
        # option - default_pleural_alias_fields: [ :name ]

        default_alias_fields         = options[:default_alias_fields] || [:name]
        default_pleural_alias_fields = options[:default_pleural_alias_fields] || [:name]

        has_many alias_table, dependent: :delete_all

        after_save :create_default_aliases

        validate do
          # alias_name = alias and id is not null
          # alias_name = alias and id != id
          find_alias = self.class.find_by_alias(self[default_alias_fields[0]])

          unless (find_alias == nil || find_alias.id == self.id)
            errors.add(:name, I18n.t("activerecord.#{self.class.name.underscore}.error.already_exists", name: find_alias.send(default_alias_fields[0])))
          end
        end

        define_method :add_alias do |alias_name|
          alias_name = alias_name.downcase()
          found_unit = self.class.find_by_alias(alias_name)

          if (found_unit != nil && found_unit.id != self.id)
            nil
          else
            alias_list = (self.send(alias_table.to_sym)).select do |alias_item|
              alias_item.alias == alias_name
            end

            if (alias_list == nil || alias_list.length == 0)
              self.send(alias_table.to_sym).build(alias: alias_name)
            else
              alias_list[0]
            end
          end
        end

        alias_metaclass.instance_eval do
          define_method :initialize_field do
            if default_alias_fields && default_alias_fields.length > 0
              initialize_field_return ||= default_alias_fields[0]
            end
            if default_pleural_alias_fields &&default_pleural_alias_fields.length > 0
              initialize_field_return ||= default_pleural_alias_fields[0]
            end

            initialize_field_return.to_sym
          end

          # This is a helper function to find an item by an alias.
          define_method :find_or_initialize do |alias_name|
            found_unit = self.find_by_alias(alias_name)
            unless found_unit
              initialize_field = self.initialize_field

              if (initialize_field)
                new_args ={ initialize_field.to_sym => alias_name }
              end

              found_unit = self.new(new_args)
            end

            found_unit
          end

          define_method :default_aliased_fields do
            default_alias_fields.clone
          end

          define_method :default_pleural_aliased_fields do
            default_pleural_alias_fields.clone
          end

          # This is a helper function to find an item by an alias.
          define_method :find_by_alias do |alias_name|
            unless alias_name == nil
              find_alias = alias_table.to_s.pluralize.classify.constantize.where(alias: "#{alias_name.downcase}").first()
            end
            unless find_alias == nil
              self.find(find_alias.send(self.name.underscore + "_id"))
            end
          end

          # This is a helper function to find items by alias with a loose match.
          define_method :search_alias do |search_string|
            search_string            ||= ""
            simplified_search_string = search_string.downcase().gsub(/[,;\.:\t]/, " ").gsub(/[^ \w]/, "_").
                gsub(/ _/, " ").gsub(/_ /, " ")

            if (search_string.blank?)
              self.index_sort
            else
              # Scopes...
              search_results  = self.scoped
              search_elements = simplified_search_string.split(" ")
              case_clause     = "(CASE WHEN alias = #{self.sanitize(search_string)} THEN 1 ELSE 0 END"
              where_clause    = "alias = #{self.sanitize(search_string)}"
              where_clause    += " OR alias like #{self.sanitize("%#{search_string}%")}"
              case_clause     += " + CASE WHEN  alias like #{self.sanitize("%#{search_string}%")} THEN 1 ELSE 0 END"

              search_elements.each do |element|
                if (search_elements.length <= 1 || element.length > 2)
                  where_clause += " OR alias like #{self.sanitize("%#{element}%")}"
                  case_clause  += " + CASE WHEN  alias like #{self.sanitize("%#{element}%")} THEN 1 ELSE 0 END"
                end
              end
              case_clause += ")"

              search_results = search_results.where(where_clause)
              search_results = search_results.order("#{case_clause} DESC").order(self.initialize_field)
              search_results = search_results.joins(alias_table)
              search_results = search_results.uniq

              search_results
            end
          end
        end

        define_method :is_default_alias? do |test_alias|
          test_alias = test_alias.downcase()

          if (default_alias_fields)
            default_alias_fields.each do |def_alias_field|
              if (self[def_alias_field] && self[def_alias_field].singularize.downcase == test_alias)
                return true
              end
            end
          end

          if (default_pleural_alias_fields)
            default_pleural_alias_fields.each do |def_alias_field|
              if (self[def_alias_field] && self[def_alias_field].pluralize.downcase == test_alias)
                return true
              end
            end
          end

          false
        end

        #protected
        define_method :create_default_aliases do
          # I want all measuring units to have their own name and abbreviation as aliases.
          if (default_alias_fields)
            default_alias_fields.each do |def_alias_field|
              if (self[def_alias_field])
                self.add_alias(self[def_alias_field].singularize).save!
              end
            end
          end

          if (default_pleural_alias_fields)
            default_pleural_alias_fields.each do |def_alias_field|
              if (self[def_alias_field])
                self.add_alias(self[def_alias_field].pluralize).save!
              end
            end
          end
        end
      end

      def aliases(aliased_table, options = {})
        # option - allow_blank: true/false - default false
        # option - allow_delete_default_aliases: true/false - default true

        allow_blank                  = options[:allow_blank] || false
        allow_delete_default_aliases = options[:allow_delete_default_aliases] == nil ? true : options[:allow_delete_default_aliases]

        attr_accessible :alias
        # ? option to specify the id field here? - yes like , but add when needed, not now.
        attr_accessible "#{aliased_table.to_s}_id".to_sym

        belongs_to aliased_table

        # option? to say if default scope is specified
        # option? to specify name field?
        #default_scope joins(aliased_table).readonly(false).order("#{aliased_table.to_s.pluralize}.name, alias")
        scope :index_sort, includes(aliased_table).
            order("#{aliased_table.to_s.pluralize}.#{aliased_table.to_s.classify.constantize.initialize_field}, alias")

        validates "#{aliased_table}".to_sym, presence: true
        validates_presence_of aliased_table

        validates :alias,
                  length:     { maximum: 255 },
                  uniqueness: { case_sensitive: false }

        unless (allow_blank)
          validates :alias,
                    presence: true,
                    length:   { minimum: 1 }
        end

        validate do
          # if allow_blank is set, we do not check for presence, so we have to check
          # for nil explicitly in the validate function.
          # This allows the value to be blank (""), but not nil.
          if (allow_blank && self.alias == nil)
            errors.add(aliased_table.to_s.classify.constantize.initialize_field, I18n.t("activerecord.#{aliased_table}.error.cannot_be_nil"))
          end
        end

        before_destroy do
          unless (allow_delete_default_aliases)
            if (self.send(aliased_table.to_sym).is_default_alias?("#{self.alias}"))
              return false
            end
          end

          true
        end

        define_method :alias do
          self[:alias]
        end

        define_method :alias= do |alias_name|
          if (alias_name)
            self[:alias] = alias_name.downcase()
          else
            self[:alias] = alias_name
          end
        end

        define_method :list_name do
          I18n.t("activerecord.#{self.class.name.underscore}.list_name",
                 alias:               self.alias,
                 aliased_table.to_sym => self.send(aliased_table).send(aliased_table.to_s.classify.constantize.initialize_field))
        end
      end
    end
  end

  module ConnectionAdapters #:nodoc:
    module SchemaStatements
      def add_alias_index(table_name, alias_of_table)
        add_index table_name, [:alias], unique: true
        add_index table_name, [(alias_of_table.to_s.singularize + "_id").to_sym]
      end
    end

    class TableDefinition
      def alias_of(alias_of_table)
        self.integer (alias_of_table.to_s.singularize + "_id").to_sym
        self.string :alias
      end
    end
  end
end