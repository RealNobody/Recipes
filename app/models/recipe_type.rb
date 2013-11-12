class RecipeType < ActiveRecord::Base
  has_many :recipes

  scope :index_sort, -> { order(:name) }

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true
end