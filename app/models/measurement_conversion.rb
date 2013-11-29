class MeasurementConversion < ActiveRecord::Base
  belongs_to :smaller_measuring_unit, class_name: "MeasuringUnit", foreign_key: :smaller_measuring_unit_id
  belongs_to :larger_measuring_unit, class_name: "MeasuringUnit", foreign_key: :larger_measuring_unit_id

  scope :index_sort, -> { includes(:smaller_measuring_unit).order("measuring_units.name, multiplier") }

  validates :smaller_measuring_unit_id, presence: true
  validates :larger_measuring_unit_id, presence: true
  validates_presence_of :smaller_measuring_unit
  validates_presence_of :larger_measuring_unit

  validates :multiplier, numericality: { greater_than_or_equal_to: 1.0 }

  validate do
    if (larger_measuring_unit_id && smaller_measuring_unit_id)
      if (MeasurementConversion.where("smaller_measuring_unit_id = #{larger_measuring_unit_id}" +
                                          " AND larger_measuring_unit_id = #{smaller_measuring_unit_id}").first != nil)
        errors.add(:smaller_measuring_unit_id, I18n.t("activerecord.measurement_conversion.error.already_exists"))
      end
    end
  end

  def list_name
    if (self.smaller_measuring_unit && self.larger_measuring_unit)
      return I18n.t("activerecord.measurement_conversion.list_name", smaller_unit: self.smaller_measuring_unit.abbreviation,
                    larger_unit:                                                   self.larger_measuring_unit.abbreviation)
    end

    nil
  end

  private
  def self.seed
    # Code while debugging conversions to clear seeds in between times.

    #puts("Removing default seeds")
    #
    #MeasurementConversion.all.each do | conversion_obj |
    #  if (!conversion_obj.larger_measuring_unit.can_delete?() && !conversion_obj.smaller_measuring_unit.can_delete?())
    #    conversion_obj.destroy()
    #  end
    #end

    puts("Seeding Conversions...")

    from_unit = MeasuringUnit.find_or_initialize("Milliliter")
    to_unit   = MeasuringUnit.find_or_initialize("Liter")
    from_unit.add_conversion(to_unit, 1000)

    from_unit = MeasuringUnit.find_or_initialize("Milliliter")
    to_unit   = MeasuringUnit.find_or_initialize("Teaspoon")
    from_unit.add_conversion(to_unit, 4.92892)

    from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
    to_unit   = MeasuringUnit.find_or_initialize("Tablespoon")
    from_unit.add_conversion(to_unit, 3)

# An approximate conversion to simplify life/conversions...
    from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
    to_unit   = MeasuringUnit.find_or_initialize("Heaping-Teaspoon")
    from_unit.add_conversion(to_unit, 1.5)

    from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
    to_unit   = MeasuringUnit.find_or_initialize("Fluid-Ounce")
    from_unit.add_conversion(to_unit, 2)

    from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
    to_unit   = MeasuringUnit.find_or_initialize("Cup")
    from_unit.add_conversion(to_unit, 16)

    from_unit = MeasuringUnit.find_or_initialize("Cup")
    to_unit   = MeasuringUnit.find_or_initialize("Pint")
    from_unit.add_conversion(to_unit, 2)

    from_unit = MeasuringUnit.find_or_initialize("Pint")
    to_unit   = MeasuringUnit.find_or_initialize("Quart")
    from_unit.add_conversion(to_unit, 2)

    from_unit = MeasuringUnit.find_or_initialize("Quart")
    to_unit   = MeasuringUnit.find_or_initialize("Gallon")
    from_unit.add_conversion(to_unit, 4)

    from_unit = MeasuringUnit.find_or_initialize("Gram")
    to_unit   = MeasuringUnit.find_or_initialize("Kilogram")
    from_unit.add_conversion(to_unit, 1000)

    from_unit = MeasuringUnit.find_or_initialize("Gram")
    to_unit   = MeasuringUnit.find_or_initialize("Ounce")
    from_unit.add_conversion(to_unit, 28.3495)

    from_unit = MeasuringUnit.find_or_initialize("Ounce")
    to_unit   = MeasuringUnit.find_or_initialize("Pound")
    from_unit.add_conversion(to_unit, 16)
  end
end