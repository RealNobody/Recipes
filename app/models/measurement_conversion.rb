class MeasurementConversion < ActiveRecord::Base
  attr_accessible :larger_measuring_unit_id, :multiplier, :smaller_measuring_unit_id

  belongs_to :smaller_measuring_unit, class_name: "MeasuringUnit", foreign_key: :smaller_measuring_unit_id
  belongs_to :larger_measuring_unit, class_name: "MeasuringUnit", foreign_key: :larger_measuring_unit_id

  default_scope joins("INNER JOIN measuring_units ON (measuring_units.id =" +
                          "measurement_conversions.smaller_measuring_unit_id)").readonly(false).order("measuring_units.name, multiplier")

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
end