class Keyword < ActiveRecord::Base
  aliased

  validates :name,
            length:   { maximum: 255, minimum: 1 },
            presence: true

  private
  def self.seed
    puts ("Seeding Keywords...")

    Keyword.find_or_initialize("Ingredients").tap do |container|
      container.name = "Ingredients"

      container.save!()
    end

    Keyword.find_or_initialize("Directions").tap do |container|
      container.name = "Directions"

      container.save!()
    end
  end
end