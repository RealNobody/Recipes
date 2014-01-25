class SearchAlias < ActiveRecord::Base
  belongs_to :aliased, polymorphic: true

  scope :index_sort, -> { order(:aliased_type, :alias) }

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
        errors.add(self.aliased_type.constantize.initialize_field, I18n.t("activerecord.#{self.aliased_type.underscore}.error.cannot_be_nil"))
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
        return false
      end
    end

    true
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

  def self.initialize_field
    :alias
  end

  def list_name
    list_name_value = I18n.t("activerecord.#{self.aliased_type.underscore}_alias.list_name",
                             alias:                              self.alias,
                             self.aliased_type.underscore.to_sym => self.aliased.send(self.aliased.class.initialize_field),
                             default:                            "")

    if list_name_value.blank?
      list_name_value = "%{alias} (%{name})" % { alias: self.alias,
                                                 name:  self.aliased.send(self.aliased.class.initialize_field) }
    end

    list_name_value
  end
end