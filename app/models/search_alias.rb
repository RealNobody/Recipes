class SearchAlias < ActiveRecord::Base
  belongs_to :aliased, polymorphic: true

  scope :index_sort, -> { order(:aliased_type, :alias) }

  paginates_per 2

  validates :aliased, presence: true

  validates :alias,
            length:     { maximum: 255 },
            uniqueness: { case_sensitive: false, scope: :aliased_type }

  validate do
    # if allow_blank is set, we do not check for presence, so we have to check
    # for nil explicitly in the validate function.
    # This allows the value to be blank (""), but not nil.
    allow_blank = self.aliased_type.try(:constantize).try(:allow_blank_aliases)
    if allow_blank
      if self.alias == nil
        aliased_class = SearchAlias
        if self.aliased_type
          aliased_class = self.aliased_type.constantize
        end

        default_value = I18n.t("activerecord.search_alias.error.cannot_be_nil_default",
                               table_name: aliased_class.model_name.human.titleize,
                               aliased_field: aliased_class.human_attribute_name(aliased_class.initialize_field))

        errors.add(:alias, I18n.t("activerecord.#{self.aliased_type.underscore}.error.cannot_be_nil", default_value))
      end
    else
      @presense_validator ||= ActiveModel::Validations::PresenceValidator.new({ attributes: :alias })
      @presense_validator.validate(self)
      @min_length_validator ||= ActiveModel::Validations::LengthValidator.new({ attributes: :alias, minimum: 1 })
      @min_length_validator.validate(self)
    end
  end

  before_destroy do
    allow_delete_default_aliases = self.aliased_type.try(:constantize).try(:allow_delete_defaults)
    unless (allow_delete_default_aliases)
      if (self.aliased.is_default_alias?("#{self.alias}"))
        default_value = I18n.t("activerecord.search_alias.error.cannot_delete_defaults_default",
                               table_name: self.aliased.class.model_name.human.titleize)
        errors.add(:alias, I18n.t("activerecord.#{self.aliased_type.underscore}.error.cannot_delete_defaults", default_value))
        return false
      end
    end

    true
  end

  class << self
    def initialize_field
      :alias
    end

    def aliased_tables
      @@aliased_tables ||= []
    end

    def add_aliased_table(aliased_class)
      SearchAlias.aliased_tables << aliased_class unless SearchAlias.aliased_tables.include?(aliased_class)
    end

    def is_class_aliased?(test_class)
      if test_class.is_a?(Symbol) || test_class.is_a?(String)
        SearchAlias.is_class_aliased?(test_class.to_s.classify.constantize)
      else
        SearchAlias.aliased_tables.include?(test_class)
      end
    end

    # This is a helper function to find items by alias with a loose match.
    #
    # Options:
    #   offset                  - The paging offset, this is the number of records to
    #                             offset, not the number of pages
    #   limit                   - The total number of items to return
    #   parent_object           - The parent object used to restrict the returned search
    #                             results.
    #   relationship            - The relationship between the parent object and the child
    #                             object (self) which defines the restriction.
    #                             The relationship is that:
    #                             <parent_class>.<relationship>_id = search_results.aliased_id
    #                             AND search_results.aliased_type = self.class
    #
    #                             If self is search_aliases, then:
    #                             search_results.aliased_type = <parent_object.class>
    #                             AND search_results.aliased_id = <parent_object.id>
    #   search_type             - The filter for the aliased_type
    #   search_type_table       - The table to return results for.
    #   search_class            - The class of the object we are searching for.
    #                             This is used to gather certain information and call queries against.
    #   parent_reference_field  - The field in the searched objects which references the parent object.
    def search_alias(search_string, options = {})
      search_class = options[:search_class] || self

      SearchAlias.search_alias_full(search_string, search_class, options)
    end

    # This does a "basic" search of the alias table.
    # See #search_alias for details on all of the parameters.
    def search_alias_full(search_string, search_class, options = {})
      offset            = options[:offset] || 0
      limit             = options[:limit] || search_class.default_per_page
      search_type_table = options[:search_type_table] || search_class.name.tableize
      search_type       = options[:search_type] || ""
      parent_ref_field  = options[:parent_reference_field]
      parent_obj        = options[:parent_object]

      if parent_obj
        parent_ref_field ||= "#{parent_obj.class.name.underscore}_id"
      end
      options[:search_class]           = search_class
      options[:search_type]            = search_type
      options[:search_type_table]      = search_type_table
      options[:parent_reference_field] = parent_ref_field

      search_query, case_clause = SearchAlias.search_alias_query_string_partials(search_string, options)

      # If there are no parameters, then do the "default" thing.
      if (search_query.blank?)
        parent_object = options[:parent_object]
        if parent_object
          return_set = parent_object.send(options[:relationship]).index_sort
          return_set = return_set.limit(limit) if (limit > 0)
          return_set = return_set.offset(offset) if (offset > 0)

          [parent_object.send(options[:relationship]).count, return_set]
        else
          return_set = search_class.index_sort
          return_set = return_set.limit(limit) if (limit > 0)
          return_set = return_set.offset(offset) if (offset > 0)

          [search_class.count, return_set]
        end
      else
        full_query = "SELECT `#{search_type_table}`.*"
        full_query << " FROM `#{search_type_table}`"
        if search_type.blank?
          full_query << " INNER JOIN (SELECT `search_aliases`.`id` AS `aliased_id`, ("
        else
          full_query << " INNER JOIN (SELECT `search_aliases`.`aliased_id`, MAX("
        end
        full_query << case_clause
        full_query << ") AS max_sort"
        full_query << search_query
        unless search_type.blank?
          full_query << " GROUP BY `search_aliases`.`aliased_id`"
        end
        full_query << ") AS `sorted_units`"
        full_query << " ON (`sorted_units`.`aliased_id` = `#{search_type_table}`.`id`)"
        full_query << " ORDER BY `sorted_units`.`max_sort` DESC,"
        full_query << " `#{search_type_table}`.`#{search_class.initialize_field}` ASC"
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

        if search_type.blank?
          count_query = "SELECT COUNT(DISTINCT `search_aliases`.`id`)"
        else
          count_query = "SELECT COUNT(DISTINCT `search_aliases`.`aliased_id`)"
        end
        count_query << search_query

        [search_class.count_by_sql(count_query), search_class.find_by_sql(full_query)]
      end
    end

    # This is a helper method to build the search criteria string for searc_alias
    # queries.
    #
    # see #search_alias for details on the options.
    def search_alias_query_string_partials(search_string_orig, options={})
      parent_object     = options[:parent_object]
      search_type       = options[:search_type]
      search_type_table = options[:search_type_table]
      parent_ref_field  = options[:parent_reference_field]

      if (parent_object)
        parent_ref_field ||= options[:parent_reference_field] || "#{parent_object.class.name.underscore}_id"
      end

      search_string            = search_string_orig.try(:clone)
      search_string            ||= ""
      search_string            = search_string.downcase()
      simplified_search_string = search_string.gsub(/[,;\.:\t]/, " ").gsub(/[^ \w]/, "_").
          gsub(/ _/, " ").gsub(/_ /, " ")

      search_query = nil
      case_clause  = nil

      unless (search_string.blank?)
        search_elements     = simplified_search_string.split(" ")
        case_clause         = "(CASE WHEN `search_aliases`.`alias` = #{self.sanitize(search_string)} THEN 1 ELSE 0 END"
        where_clause        = "`search_aliases`.`alias` = #{self.sanitize(search_string)}"
        where_clause        += " OR `search_aliases`.`alias` like #{self.sanitize("%#{search_string}%")}"
        case_clause         += " + CASE WHEN `search_aliases`.`alias` like #{self.sanitize("%#{search_string}%")} THEN 1 ELSE 0 END"
        parent_join_clause  = ""
        parent_where_clause = ""

        if (parent_object)
          if search_type.blank?
            parent_where_clause << "`search_aliases`.`aliased_id` = #{parent_object.id}"
            search_type = parent_object.class.name
          else
            parent_join_clause << " INNER JOIN `#{search_type_table}` ON ("
            parent_join_clause << "`search_aliases`.`aliased_id` = `#{search_type_table}`.`id`"
            parent_join_clause << " AND `search_aliases`.`aliased_type` = '#{search_type}'"
            parent_join_clause << " AND `#{search_type_table}`.`#{parent_ref_field}` = #{parent_object.id}"
            parent_join_clause << ")"
          end
        end

        search_elements.each do |element|
          if (search_elements.length <= 1 || element.length > 2)
            where_clause += " OR `search_aliases`.`alias` like #{self.sanitize("%#{element}%")}"
            case_clause  += " + CASE WHEN `search_aliases`.`alias` like #{self.sanitize("%#{element}%")} THEN 1 ELSE 0 END"
          end
        end
        case_clause += ")"

        search_query = " FROM `search_aliases`"
        unless parent_join_clause.blank?
          search_query << parent_join_clause
        end
        search_query << " WHERE ("
        search_query << where_clause
        search_query << ")"
        unless search_type.blank?
          search_query << " AND `search_aliases`.`aliased_type` = '#{search_type}'"
        end
        unless parent_where_clause.blank?
          search_query << " AND (#{parent_where_clause})"
        end
      end

      [search_query, case_clause]
    end
  end

  def alias
    self[:alias]
  end

  def alias=(alias_name)
    if (alias_name)
      self[:alias] = alias_name.downcase()
    else
      self[:alias] = alias_name
    end
  end

  def list_name
    if (aliased_type.blank?)
      I18n.t("activerecord.search_alias.new_label")
    else
      I18n.t("activerecord.#{self.aliased_type.underscore}_alias.list_name",
             alias:   self.alias,
             name:    self.aliased.send(self.aliased.class.initialize_field),
             default: "%{alias} (%{name})")
    end
  end
end