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
  attr_accessible :alias
  belongs_to :measuring_unit

  validates :alias,
            length:     { maximum: 255 },
            uniqueness: { case_sensitive: false }

  def alias
    self[:alias]
  end

  def alias=(alias_name)
    self[:alias] = alias_name.downcase()
  end
end