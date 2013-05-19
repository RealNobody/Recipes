class Object
  def alias_metaclass
    class << self;
      self
    end
  end
end

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

        alias_metaclass.instance_eval do
          # This is a helper function to find a measurement by an alias.
          define_method :find_or_initialize do |alias_name|
            found_unit = self.find_by_alias(alias_name)
            if found_unit == nil
              found_unit = self.new(name: alias_name)
            else
              found_unit
            end
          end
        end

        define_method :add_alias do |alias_name|
          alias_name = alias_name.downcase()
          found_unit = self.class.find_by_alias(alias_name)

          if (found_unit != nil && found_unit.id != self.id)
            nil
          else
            alias_list = eval("self.#{alias_table}.select do |alias_item|\nalias_item.alias == alias_name\nend")

            if (alias_list == nil || alias_list.length == 0)
              new_alias = eval("self.#{alias_table}.build(alias: alias_name)")
            else
              alias_list[0]
            end
          end
        end

        alias_metaclass.instance_eval do
          # This is a helper function to find a measurement by an alias.
          define_method :find_by_alias do |alias_name|
            unless alias_name == nil
              find_alias = eval("#{alias_table.to_s.pluralize.classify}.where(alias: \"#{alias_name.downcase()}\").first()")
            end
            unless find_alias == nil
              self.find(find_alias.send(self.name.underscore + "_id"))
            end
          end
        end

        alias_metaclass.instance_eval do
          # This is a helper function to find items by alias with a loose match.
          define_method :search_alias do |search_string|
            search_string   = search_string.downcase().gsub(/[,;:\t]/, " ").gsub(/[^ \w]/, "_").gsub(/ _/, " ").gsub(/_ /,
                                                                                                                     " ")
            # Scopes...

            search_results  = self.scoped
            search_elements = search_string.split(" ")
            case_clause     = "(CASE WHEN alias = #{self.sanitize(search_string)} THEN 1 ELSE 0 END"
            where_clause    = "alias = #{self.sanitize(search_string)}"

            search_elements.each do |element|
              if (search_elements.length <= 1 || element.length > 2)
                where_clause += " OR alias like #{self.sanitize("%#{element}%")}"
                case_clause  += " + CASE WHEN  alias like #{self.sanitize("%#{element}%")} THEN 1 ELSE 0 END"
              end
            end
            case_clause += ")"

            search_results = search_results.where(where_clause)
            search_results = search_results.order("#{case_clause} DESC").order(:name)
            search_results = search_results.joins(alias_table)
            search_results = search_results.uniq
            #search_results = search_results.select("name, #{case_clause} AS search_weight, measuring_units.id")

            search_results
          end
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

        define_method :is_default_alias do |test_alias|
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
        scope :index_sort, includes(aliased_table).order("#{aliased_table.to_s.pluralize}.name, alias")

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
            errors.add(:name, I18n.t("activerecord.#{aliased_table}.error.cannot_be_nil"))
          end
        end

        before_destroy do
          unless (allow_delete_default_aliases)
            if (eval("self.#{aliased_table}.is_default_alias(\"#{self.alias}\")"))
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
          eval("I18n.t(\"activerecord.#{self.class.name.underscore}.list_name\", alias: self.alias, #{aliased_table}: self.#{aliased_table}.name)")
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