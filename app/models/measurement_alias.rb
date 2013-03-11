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

  validates :measuring_unit_id, presence: true
  validates_presence_of :measuring_unit

  validates :alias,
            presence:   true,
            length:     { minimum: 1, maximum: 255 },
            uniqueness: { case_sensitive: false }

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
    I18n.t("activerecord.measurement_alias.list_name", alias: self.alias, measuring_unit: self.measuring_unit.name)
  end
end