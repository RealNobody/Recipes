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
        aliased_table         = aliased_class.name.underscore.pluralize

        has_many :search_aliases, as: :aliased

        after_save :create_default_aliases

        scope :index_sort, index_sort_scope

        validate do
          # alias_name = alias and id is not null
          # alias_name = alias and id != id
          find_alias = self.class.find_by_alias(self[self.class.initialize_field])

          unless (find_alias == nil || find_alias.id == self.id)
            errors.add(:name, I18n.t("activerecord.#{self.class.name.underscore}.error.already_exists",
                                     name: find_alias[self.class.initialize_field]))
          end
        end

        SearchAlias.class_eval do
          scope "#{aliased_class.name.underscore}_index_sort".to_sym, -> { joins("LEFT JOIN `#{aliased_table}` ON (`#{aliased_table}`.`id` = `search_aliases`.`aliased_id`)").
              where(aliased_type: aliased_class.name).
              order("#{aliased_class.name.underscore.pluralize}.#{aliased_class.initialize_field}, search_aliases.alias") }
        end

        define_method :list_name do
          list_name_value = I18n.t("activerecord.#{self.class.name.underscore}.list_name",
                                   self.class.name.underscore.to_sym => self.send(self.class.initialize_field),
                                   default:                             "")

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
          define_method :allow_blank_aliases do
            allow_blank_aliases
          end

          define_method :allow_delete_defaults do
            allow_delete_defaults
          end

          define_method :initialize_field do
            if alias_fields && alias_fields.length > 0
              initialize_field_return ||= alias_fields[0]
            end
            if pleural_alias_fields &&pleural_alias_fields.length > 0
              initialize_field_return ||= pleural_alias_fields[0]
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

          define_method :default_aliased_fields do
            alias_fields.clone
          end

          define_method :default_pleural_aliased_fields do
            pleural_alias_fields.clone
          end

          define_method :aliased_fields do
            alias_fields.clone
          end

          define_method :pleural_aliased_fields do
            pleural_alias_fields.clone
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
          define_method :search_alias do |search_string, offset = 0, limit = 0|
            search_type_table        = self.name.underscore.pluralize
            search_type              = self.name
            search_string            ||= ""
            search_string            = search_string.downcase()
            simplified_search_string = search_string.gsub(/[,;\.:\t]/, " ").gsub(/[^ \w]/, "_").
                gsub(/ _/, " ").gsub(/_ /, " ")

            if (search_string.blank?)
              return_set = self.index_sort
              return_set = return_set.limit(limit) if (limit > 0)
              return_set = return_set.offset(offset) if (offset > 0)

              [self.all.count, return_set]
            else
              # Scopes...
              search_elements = simplified_search_string.split(" ")
              case_clause     = "(CASE WHEN `search_aliases`.`alias` = #{self.sanitize(search_string)} THEN 1 ELSE 0 END"
              where_clause    = "`search_aliases`.`alias` = #{self.sanitize(search_string)}"
              where_clause    += " OR `search_aliases`.`alias` like #{self.sanitize("%#{search_string}%")}"
              case_clause     += " + CASE WHEN `search_aliases`.`alias` like #{self.sanitize("%#{search_string}%")} THEN 1 ELSE 0 END"

              search_elements.each do |element|
                if (search_elements.length <= 1 || element.length > 2)
                  where_clause += " OR `search_aliases`.`alias` like #{self.sanitize("%#{element}%")}"
                  case_clause  += " + CASE WHEN `search_aliases`.`alias` like #{self.sanitize("%#{element}%")} THEN 1 ELSE 0 END"
                end
              end
              case_clause += ")"

              full_query = "SELECT `#{search_type_table}`.*"
              full_query << " FROM `#{search_type_table}`"
              full_query << " INNER JOIN (SELECT `search_aliases`.`aliased_id`, MAX("
              full_query << case_clause
              full_query << ") AS max_sort"
              full_query << " FROM `search_aliases`"
              full_query << " WHERE `search_aliases`.`aliased_type` = '#{search_type}' AND ("
              full_query << where_clause
              full_query << ") GROUP BY `search_aliases`.`aliased_id`)"
              full_query << " AS `sorted_units`"
              full_query << " ON (`sorted_units`.`aliased_id` = `#{search_type_table}`.`id`)"
              full_query << " ORDER BY `sorted_units`.`max_sort` DESC,"
              full_query << " `#{search_type_table}`.`#{self.initialize_field}` ASC"
              if (offset > 0 || limit > 0)
                full_query << " LIMIT "
                if (offset > 0)
                  full_query << offset.to_s
                  if (limit > 0)
                    full_query << ", "
                  end
                end
                if (limit > 0)
                  full_query << limit.to_s
                end
              end

              count_query = "SELECT COUNT(DISTINCT `search_aliases`.`aliased_id`)"
              count_query << " FROM `search_aliases`"
              count_query << " WHERE `search_aliases`.`aliased_type` = '#{search_type}' AND ("
              count_query << where_clause
              count_query << ")"

              [self.count_by_sql(count_query), self.find_by_sql(full_query)]
            end
          end
        end

        define_method :is_default_alias? do |test_alias|
          test_alias = test_alias.downcase()

          if (alias_fields)
            alias_fields.each do |alias_field|
              if (self[alias_field] && self[alias_field].singularize.downcase == test_alias)
                return true
              end
            end
          end

          if (pleural_alias_fields)
            pleural_alias_fields.each do |alias_field|
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
          if (alias_fields)
            alias_fields.each do |alias_field|
              if (self[alias_field])
                self.add_alias(self[alias_field].singularize).save!
              end
            end
          end

          if (pleural_alias_fields)
            pleural_alias_fields.each do |alias_field|
              if (self[alias_field])
                self.add_alias(self[alias_field].pluralize).save!
              end
            end
          end
        end
      end

      #def aliased_by(alias_table, options = {})
      #  # option - default_alias_fields: [ :name ]
      #  # option - default_pleural_alias_fields: [ :name ]
      #  # option - index_sort: -> { order(initialize_field[0])}
      #
      #  default_alias_fields         = options[:default_alias_fields] || [:name]
      #  default_pleural_alias_fields = options[:default_pleural_alias_fields] || [:name]
      #  index_sort_scope             = options[:index_sort] || -> { order(:name) }
      #
      #  has_many alias_table, dependent: :delete_all
      #
      #  after_save :create_default_aliases
      #
      #  #default_scope order(:name)
      #  scope :index_sort, index_sort_scope
      #
      #  validate do
      #    # alias_name = alias and id is not null
      #    # alias_name = alias and id != id
      #    find_alias = self.class.find_by_alias(self[default_alias_fields[0]])
      #
      #    unless (find_alias == nil || find_alias.id == self.id)
      #      errors.add(:name, I18n.t("activerecord.#{self.class.name.underscore}.error.already_exists", name: find_alias.send(default_alias_fields[0])))
      #    end
      #  end
      #
      #  define_method :add_alias do |alias_name|
      #    alias_name = alias_name.downcase()
      #    found_unit = self.class.find_by_alias(alias_name)
      #
      #    if (found_unit != nil && found_unit.id != self.id)
      #      nil
      #    else
      #      alias_list = (self.send(alias_table.to_sym)).select do |alias_item|
      #        alias_item.alias == alias_name
      #      end
      #
      #      if (alias_list == nil || alias_list.length == 0)
      #        self.send(alias_table.to_sym).build(alias: alias_name)
      #      else
      #        alias_list[0]
      #      end
      #    end
      #  end
      #
      #  alias_metaclass.instance_eval do
      #    define_method :initialize_field do
      #      if default_alias_fields && default_alias_fields.length > 0
      #        initialize_field_return ||= default_alias_fields[0]
      #      end
      #      if default_pleural_alias_fields &&default_pleural_alias_fields.length > 0
      #        initialize_field_return ||= default_pleural_alias_fields[0]
      #      end
      #
      #      initialize_field_return.to_sym
      #    end
      #
      #    # This is a helper function to find an item by an alias.
      #    define_method :find_or_initialize do |alias_name|
      #      found_unit = self.find_by_alias(alias_name)
      #      unless found_unit
      #        initialize_field = self.initialize_field
      #
      #        if (initialize_field)
      #          new_args ={ initialize_field.to_sym => alias_name }
      #        end
      #
      #        found_unit = self.new(new_args)
      #      end
      #
      #      found_unit
      #    end
      #
      #    define_method :default_aliased_fields do
      #      default_alias_fields.clone
      #    end
      #
      #    define_method :default_pleural_aliased_fields do
      #      default_pleural_alias_fields.clone
      #    end
      #
      #    # This is a helper function to find an item by an alias.
      #    define_method :find_by_alias do |alias_name|
      #      unless alias_name == nil
      #        find_alias = alias_table.to_s.pluralize.classify.constantize.where(alias: "#{alias_name.downcase}").first()
      #      end
      #      unless find_alias == nil
      #        self.find(find_alias.send(self.name.underscore + "_id"))
      #      end
      #    end
      #
      #    # This is a helper function to find items by alias with a loose match.
      #    define_method :search_alias do |search_string, offset = 0, limit = 0|
      #      search_string            ||= ""
      #      search_string            = search_string.downcase()
      #      simplified_search_string = search_string.gsub(/[,;\.:\t]/, " ").gsub(/[^ \w]/, "_").
      #          gsub(/ _/, " ").gsub(/_ /, " ")
      #
      #      if (search_string.blank?)
      #        return_set = self.index_sort
      #        return_set = return_set.limit(limit) if (limit > 0)
      #        return_set = return_set.offset(offset) if (offset > 0)
      #
      #        [self.all.count, return_set]
      #      else
      #        # Scopes...
      #        search_elements = simplified_search_string.split(" ")
      #        case_clause     = "(CASE WHEN `#{alias_table.to_s.pluralize}`.`alias` = #{self.sanitize(search_string)} THEN 1 ELSE 0 END"
      #        where_clause    = "`#{alias_table.to_s.pluralize}`.`alias` = #{self.sanitize(search_string)}"
      #        where_clause    += " OR `#{alias_table.to_s.pluralize}`.`alias` like #{self.sanitize("%#{search_string}%")}"
      #        case_clause     += " + CASE WHEN `#{alias_table.to_s.pluralize}`.`alias` like #{self.sanitize("%#{search_string}%")} THEN 1 ELSE 0 END"
      #
      #        search_elements.each do |element|
      #          if (search_elements.length <= 1 || element.length > 2)
      #            where_clause += " OR `#{alias_table.to_s.pluralize}`.`alias` like #{self.sanitize("%#{element}%")}"
      #            case_clause  += " + CASE WHEN `#{alias_table.to_s.pluralize}`.`alias` like #{self.sanitize("%#{element}%")} THEN 1 ELSE 0 END"
      #          end
      #        end
      #        case_clause += ")"
      #
      #        full_query = "SELECT `#{self.name.underscore.pluralize}`.*"
      #        full_query << " FROM `#{self.name.underscore.pluralize}`"
      #        full_query << " INNER JOIN (SELECT `#{alias_table.to_s.pluralize}`.`#{self.name.underscore}_id`, MAX("
      #        full_query << case_clause
      #        full_query << ") AS max_sort"
      #        full_query << " FROM `#{alias_table.to_s.pluralize}`"
      #        full_query << " WHERE ("
      #        full_query << where_clause
      #        full_query << ") GROUP BY `#{alias_table.to_s.pluralize}`.`#{self.name.underscore}_id`)"
      #        full_query << " AS `sorted_units`"
      #        full_query << " ON (`sorted_units`.`#{self.name.underscore}_id` = `#{self.name.underscore.pluralize}`.`id`)"
      #        full_query << " ORDER BY `sorted_units`.`max_sort` DESC,"
      #        full_query << " `#{self.name.underscore.pluralize}`.`#{self.initialize_field}` ASC"
      #        if (offset > 0 || limit > 0)
      #          full_query << " LIMIT "
      #          if (offset > 0)
      #            full_query << offset.to_s
      #            if (limit > 0)
      #              full_query << ", "
      #            end
      #          end
      #          if (limit > 0)
      #            full_query << limit.to_s
      #          end
      #        end
      #
      #        count_query = "SELECT COUNT(DISTINCT `#{alias_table.to_s.pluralize}`.`#{self.name.underscore}_id`)"
      #        count_query << " FROM `#{alias_table.to_s.pluralize}`"
      #        count_query << " WHERE ("
      #        count_query << where_clause
      #        count_query << ")"
      #
      #        [self.count_by_sql(count_query), self.find_by_sql(full_query)]
      #      end
      #    end
      #  end
      #
      #  define_method :is_default_alias? do |test_alias|
      #    test_alias = test_alias.downcase()
      #
      #    if (default_alias_fields)
      #      default_alias_fields.each do |def_alias_field|
      #        if (self[def_alias_field] && self[def_alias_field].singularize.downcase == test_alias)
      #          return true
      #        end
      #      end
      #    end
      #
      #    if (default_pleural_alias_fields)
      #      default_pleural_alias_fields.each do |def_alias_field|
      #        if (self[def_alias_field] && self[def_alias_field].pluralize.downcase == test_alias)
      #          return true
      #        end
      #      end
      #    end
      #
      #    false
      #  end
      #
      #  #protected
      #  define_method :create_default_aliases do
      #    # I want all measuring units to have their own name and abbreviation as aliases.
      #    if (default_alias_fields)
      #      default_alias_fields.each do |def_alias_field|
      #        if (self[def_alias_field])
      #          self.add_alias(self[def_alias_field].singularize).save!
      #        end
      #      end
      #    end
      #
      #    if (default_pleural_alias_fields)
      #      default_pleural_alias_fields.each do |def_alias_field|
      #        if (self[def_alias_field])
      #          self.add_alias(self[def_alias_field].pluralize).save!
      #        end
      #      end
      #    end
      #  end
      #end

      #def aliases(aliased_table, options = {})
      #  # option - allow_blank: true/false - default false
      #  # option - allow_delete_default_aliases: true/false - default true
      #
      #  allow_blank                  = options[:allow_blank] || false
      #  allow_delete_default_aliases = options[:allow_delete_default_aliases] == nil ? true : options[:allow_delete_default_aliases]
      #
      #  belongs_to aliased_table
      #
      #  # option? to say if default scope is specified
      #  # option? to specify name field?
      #  #default_scope joins(aliased_table).readonly(false).order("#{aliased_table.to_s.pluralize}.name, alias")
      #  scope :index_sort, -> { includes(aliased_table).
      #      order("#{aliased_table.to_s.pluralize}.#{aliased_table.to_s.classify.constantize.initialize_field}, alias") }
      #
      #  validates "#{aliased_table}".to_sym, presence: true
      #  validates_presence_of aliased_table
      #
      #  validates :alias,
      #            length:     { maximum: 255 },
      #            uniqueness: { case_sensitive: false }
      #
      #  unless (allow_blank)
      #    validates :alias,
      #              presence: true,
      #              length:   { minimum: 1 }
      #  end
      #
      #  validate do
      #    # if allow_blank is set, we do not check for presence, so we have to check
      #    # for nil explicitly in the validate function.
      #    # This allows the value to be blank (""), but not nil.
      #    if (allow_blank && self.alias == nil)
      #      errors.add(aliased_table.to_s.classify.constantize.initialize_field, I18n.t("activerecord.#{aliased_table}.error.cannot_be_nil"))
      #    end
      #  end
      #
      #  before_destroy do
      #    unless (allow_delete_default_aliases)
      #      if (self.send(aliased_table.to_sym).is_default_alias?("#{self.alias}"))
      #        return false
      #      end
      #    end
      #
      #    true
      #  end
      #
      #  define_method :alias do
      #    self[:alias]
      #  end
      #
      #  define_method :alias= do |alias_name|
      #    if (alias_name)
      #      self[:alias] = alias_name.downcase()
      #    else
      #      self[:alias] = alias_name
      #    end
      #  end
      #
      #  alias_metaclass.instance_eval do
      #    define_method :initialize_field do
      #      :alias
      #    end
      #  end
      #
      #  define_method :list_name do
      #    I18n.t("activerecord.#{self.class.name.underscore}.list_name",
      #           alias:               self.alias,
      #           aliased_table.to_sym => self.send(aliased_table).send(aliased_table.to_s.classify.constantize.initialize_field))
      #  end
      #end
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