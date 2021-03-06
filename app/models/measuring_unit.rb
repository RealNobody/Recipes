# == Schema Information
#
# Table name: measuring_units
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class MeasuringUnit < ActiveRecord::Base
  aliased_by :measurement_aliases, allow_delete_default_aliases: false, default_alias_fields: [:name, :abbreviation], default_pleural_alias_fields: [:name]

  attr_accessible :name, :abbreviation
  attr_protected :can_delete

  has_many :larger_measurement_conversions, dependent: :delete_all, class_name: "MeasurementConversion",
           foreign_key:                                :smaller_measuring_unit_id
  has_many :smaller_measurement_conversions, dependent: :delete_all, class_name: "MeasurementConversion",
           foreign_key:                                 :larger_measuring_unit_id

  has_many :larger_measuring_units, through: :larger_measurement_conversions
  has_many :smaller_measuring_units, through: :smaller_measurement_conversions

  has_many :ingredients

  #default_scope order("name")
  scope :index_sort, order("name")
  paginates_per 2

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  validates :abbreviation,
            length: { maximum: 255 }

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
    self[:name] = name
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

  def add_conversion(convert_to_measuring_unit, conversion_multiplier)
    convert_to_measuring_unit = MeasuringUnit.find(convert_to_measuring_unit.id)
    self_unit                 = MeasuringUnit.find(self.id)

    # a = self
    # b = convert to unit
    # c = current convert unit
    # x = multiplication factor
    # y = existing multiplication factor

    # a * x = b (what we are adding.)

    # Add conversions of c -> b where a -> c exists
    self_unit.larger_measurement_conversions.each do |larger_unit|
      # c = larger_unit.larger_measuring_unit_id
      # a * y = c
      # a = b / x
      # b * y / x = c

      if (larger_unit.larger_measuring_unit_id != convert_to_measuring_unit.id)
        MeasuringUnit.basic_conversion_add(convert_to_measuring_unit.id, larger_unit.larger_measuring_unit_id,
                                           larger_unit.multiplier / conversion_multiplier)
      end
    end

    # Add conversions of c -> b where c -> a exists
    self_unit.smaller_measurement_conversions.each do |smaller_unit|
      # c = smaller_unit.smaller_measuring_unit_id
      # c * y = a
      # c * y * x = b

      if (smaller_unit.smaller_measuring_unit_id != convert_to_measuring_unit.id)
        MeasuringUnit.basic_conversion_add(smaller_unit.smaller_measuring_unit_id, convert_to_measuring_unit.id,
                                           smaller_unit.multiplier * conversion_multiplier)
      end
    end

    # Add conversions of a -> c where b -> c exists
    convert_to_measuring_unit.larger_measurement_conversions.each do |larger_unit|
      # c = larger_unit.larger_measuring_unit_id
      # b * y = c
      # a * x * y = c

      if (larger_unit.larger_measuring_unit_id != self.id)
        MeasuringUnit.basic_conversion_add(self.id, larger_unit.larger_measuring_unit_id,
                                           larger_unit.multiplier * conversion_multiplier)
      end
    end

    # Add conversions of a -> c where c -> b exists
    convert_to_measuring_unit.smaller_measurement_conversions.each do |smaller_unit|
      # c = smaller_unit.smaller_measuring_unit_id
      # c * y = b
      # a * x = c * y
      # a * x / y = c

      if (smaller_unit.smaller_measuring_unit_id != self.id)
        MeasuringUnit.basic_conversion_add(self.id, smaller_unit.smaller_measuring_unit_id,
                                           conversion_multiplier / smaller_unit.multiplier)
      end
    end

    # now add the conversion we started with...
    MeasuringUnit.basic_conversion_add(self.id, convert_to_measuring_unit.id, conversion_multiplier)
  end

  def can_convert_to(convert_measuring_unit)
    self.smaller_measuring_units.include?(convert_measuring_unit) ||
        self.larger_measuring_units.include?(convert_measuring_unit)
  end

  def convert_to(convert_measuring_unit)
    self.smaller_measurement_conversions.each do |smaller_unit|
      if (smaller_unit.smaller_measuring_unit_id == convert_measuring_unit.id)
        return 1.0 / smaller_unit.multiplier
      end
    end

    self.larger_measurement_conversions.each do |larger_unit|
      if (larger_unit.larger_measuring_unit_id == convert_measuring_unit.id)
        return larger_unit.multiplier
      end
    end

    return 1
  end

  private
  def self.basic_conversion_add (from_id, to_id, multiplier)
    if (multiplier < 1)
      smaller_id = to_id
      larger_id  = from_id
      multiplier = 1.0 / multiplier
    else
      smaller_id = from_id
      larger_id  = to_id
    end

    found_unit = MeasurementConversion.where("(smaller_measuring_unit_id = #{smaller_id}" +
                                                 " AND larger_measuring_unit_id = #{larger_id})" +
                                                 " OR (smaller_measuring_unit_id = #{larger_id}" +
                                                 " AND larger_measuring_unit_id = #{smaller_id})").first()
    found_unit ||= MeasurementConversion.create(smaller_measuring_unit_id: smaller_id,
                                                larger_measuring_unit_id:  larger_id, multiplier: multiplier)

    found_unit.multiplier = multiplier
    found_unit.save!()
  end
end