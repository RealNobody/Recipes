# == Schema Information
#
# Table name: measuring_units
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#  search_name  :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class MeasuringUnit < ActiveRecord::Base
  attr_accessible :name, :abbreviation
  attr_protected :can_delete

  has_many :measurement_aliases, dependent: :delete_all

  default_scope order("name")
  paginates_per 2

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  validates :search_name,
            length:     { maximum: 255, minimum: 1 },
            presence:   true,
            uniqueness: { case_sensitive: false }

  validates :abbreviation,
            length: { maximum: 255 }

  after_save do
    # I want all measuring units to have their own name and abbreviation as aliases.
    self.add_alias(self.name).save!()
    self.add_alias(self.name.pluralize()).save!()

    unless self.abbreviation == nil
      self.add_alias(self.abbreviation).save!()
    end
  end

  before_destroy do
    self[:can_delete]
  end

  after_initialize do
    if (self[:can_delete] == false || self[:can_delete] == 0)
      self[:can_delete] = false
    else
      self[:can_delete] = true
    end
  end

  def name=(name)
    self[:name]        = name
    self[:search_name] = name.downcase()
  end

  def name
    self[:name]
  end

  def has_abbreviation= unit_has_abbreviation
    unless unit_has_abbreviation
      self[:abbreviation] = nil
    end
  end

  def has_abbreviation
    return self.has_abbreviation?
  end

  def has_abbreviation?
    self[:abbreviation] != nil
  end

  def abbreviation
    if (self[:abbreviation] == nil)
      self[:name]
    else
      self[:abbreviation]
    end
  end

  def list_name
    return_name=self.name
    unless (self.abbreviation.blank? || self.name == self.abbreviation)
      return_name += " (#{self.abbreviation})"
    end
    return_name
  end

  # This is a helper function for seeding, but may be helpful
  # later for user defined units.
  def self.find_or_intialize(alias_name)
    found_unit = MeasuringUnit.find_by_alias(alias_name)
    if found_unit == nil
      found_unit = MeasuringUnit.new(name: alias_name)
    else
      found_unit
    end
  end

  def add_alias(alias_name)
    alias_name = alias_name.downcase()
    alias_list = self.measurement_aliases.select do |measurement_alias|
      measurement_alias.alias == alias_name
    end

    if (alias_list == nil || alias_list.length == 0)
      new_alias = self.measurement_aliases.build(alias: alias_name)
    else
      alias_list[0]
    end
  end

  # This is a helper function to find a measurement by an alias.
  def self.find_by_alias(alias_name)
    find_alias = MeasurementAlias.where(alias: alias_name.downcase()).first()
    unless find_alias == nil
      MeasuringUnit.find(find_alias.measuring_unit_id)
    end
  end
end