# == Schema Information
#
# Table name: measurement_aliases
#
#  id                :integer(4)      not null, primary key
#  alias             :string(255)
#  measuring_unit_id :integer(4)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class MeasurementAlias < ActiveRecord::Base
  attr_accessible :alias, :measuring_unit_id

  belongs_to :measuring_unit

  default_scope joins(:measuring_unit).readonly(false).order("measuring_units.name, alias")

  validates :alias,
            length:     { maximum: 255 },
            uniqueness: { case_sensitive: false }

  def alias
    self[:alias]
  end

  def alias=(alias_name)
    self[:alias] = alias_name.downcase()
  end

  def list_name
    "#{self.alias} (#{self.measuring_unit.name})"
  end
end