class PrepOrder < ActiveRecord::Base
  has_many :recipes

  scope :index_sort, -> { order("prep_orders.order, name") }

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  private
  def self.seed
    puts("Seeding Prep Orders...")

    PrepOrder.find_or_initialize_by(name: "Day Before").tap do |prep_order|
      prep_order.name  = "Day Before"
      prep_order.order = 1

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Crock Pot").tap do |prep_order|
      prep_order.name  = "Crock Pot"
      prep_order.order = 2

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Label and Freeze").tap do |prep_order|
      prep_order.name  = "Label and Freeze"
      prep_order.order = 3

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Marinade").tap do |prep_order|
      prep_order.name  = "Marinade"
      prep_order.order = 4

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Chicken Dish").tap do |prep_order|
      prep_order.name  = "Chicken Dish"
      prep_order.order = 5

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Beef Dish").tap do |prep_order|
      prep_order.name  = "Beef Dish"
      prep_order.order = 6

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Other Dish").tap do |prep_order|
      prep_order.name  = "Other Dish"
      prep_order.order = 7

      prep_order.save!()
    end

    PrepOrder.find_or_initialize_by(name: "Anytime").tap do |prep_order|
      prep_order.name  = "Anytime"
      prep_order.order = 1000000000

      prep_order.save!()
    end
  end
end