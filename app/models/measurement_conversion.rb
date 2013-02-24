class MeasurementConversion < ActiveRecord::Base
  attr_accessible :larger_measuring_unit_id, :multiplier, :smaller_measuring_unit_id

  belongs_to :smaller_measuring_unit, class_name: "MeasuringUnit", foreign_key: :smaller_measuring_unit_id
  belongs_to :larger_measuring_unit, class_name: "MeasuringUnit", foreign_key: :larger_measuring_unit_id

  default_scope joins("INNER JOIN measuring_units ON (measuring_units.id =" +
                          "measurement_conversions.smaller_measuring_unit_id)").order("measuring_units.name, multiplier")

  validates :smaller_measuring_unit_id, presence: true
  validates :larger_measuring_unit_id, presence: true

  validates :multiplier, numericality: { greater_than_or_equal_to: 1.0 }

  validate do
    if (MeasurementConversion.where("smaller_measuring_unit_id = #{larger_measuring_unit_id}" +
                                        " AND larger_measuring_unit_id = #{smaller_measuring_unit_id}").first != nil)
      errors.add(:smaller_measuring_unit_id, I18n.t("activerecord.measurement_conversion.error.already_exists"))
    end
  end

  def list_name
    return "#{self.smaller_measuring_unit.abbreviation} to #{self.larger_measuring_unit.abbreviation}"
  end
end