# == Schema Information
#
# Table name: measuring_units
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  abreviation :string(255)
#  search_name :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class MeasuringUnit < ActiveRecord::Base
  attr_accessible :name, :abreviation
  has_many :measurement_aliases

  default_scope order("name")
  paginates_per 4

  validates :name,
            length:     { maximum: 255, minimum: 1 },
            presence:   true

  validates :search_name,
            length:     { maximum: 255, minimum: 1 },
            presence:   true,
            uniqueness: { case_sensitive: false }

  validates :abreviation,
            length:     { maximum: 255 }

  after_save do
    # I want all measuring units to have their own name and abreviation as aliases.
    self.add_alias(self.name).save!()
    self.add_alias(self.name.pluralize()).save!()

    unless self.abreviation == nil
      self.add_alias(self.abreviation).save!()
    end
  end

  def name=(name)
    self[:name] = name
    self[:search_name] = name.downcase()
  end

  def name
    self[:name]
  end

  def abreviation
    if (self[:abreviation] == nil)
      self[:name]
    else
      self[:abreviation]
    end
  end

  def list_name
    return_name=self.name
    unless (self.abreviation.blank? || self.name == self.abreviation)
      return_name += " (#{self.abreviation})"
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
    alias_list = self.measurement_aliases.select do | measurement_alias |
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