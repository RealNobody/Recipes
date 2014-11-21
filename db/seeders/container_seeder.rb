class ContainerSeeder
  def self.seed
    puts("Seeding Containers...")

    Container.find_or_initialize("10 Inch Pie Plate").tap do |container|
      container.name = "10 Inch Pie Plate"

      container.save!()
    end

    Container.find_or_initialize("Gallon Freezer Bag").tap do |container|
      container.name = "Gallon Freezer Bag"

      container.save!()
    end

    Container.find_or_initialize("Quart Freezer Bag").tap do |container|
      container.name = "Quart Freezer Bag"

      container.save!()
    end

    Container.find_or_initialize("13x9x2 inch Pyrex Pan").tap do |container|
      container.name = "13x9x2 inch Pyrex Pan"

      container.save!()
    end

    Container.find_or_initialize("11x7x1 1/2 inch Pyrex Pan").tap do |container|
      container.name = "11x7x1 1/2 inch Pyrex Pan"

      container.save!()
    end

    Container.find_or_initialize("Feet Aluminum Foil").tap do |container|
      container.name = "Feet Aluminum Foil"

      container.save!()
    end

    Container.find_or_initialize("9x5x3 inch Loaf Pan").tap do |container|
      container.name = "9x5x3 inch Loaf Pan"

      container.save!()
    end

    Container.find_or_initialize("Sandwich Bag").tap do |container|
      container.name = "Sandwich Bag"

      container.save!()
    end

    Container.find_or_initialize("8x8x2 inch Baking Dish").tap do |container|
      container.name = "8x8x2 inch Baking Dish"

      container.save!()
    end

    Container.find_or_initialize("4 Cup Freezer Container").tap do |container|
      container.name = "4 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("3 Cup Freezer Container").tap do |container|
      container.name = "3 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("6 Cup Freezer Container").tap do |container|
      container.name = "6 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("8 Cup Freezer Container").tap do |container|
      container.name = "8 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("1 Cup Freezer Container").tap do |container|
      container.name = "1 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("9 inch Pie Plate").tap do |container|
      container.name = "9 inch Pie Plate"

      container.save!()
    end

    Container.find_or_initialize("9.5 Cup Freezer Container").tap do |container|
      container.name = "9.5 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("2.5 Cup Freezer Container").tap do |container|
      container.name = "2.5 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("15 Cup Freezer Container").tap do |container|
      container.name = "15 Cup Freezer Container"

      container.save!()
    end

    Container.find_or_initialize("3 1/4 Cup Round").tap do |container|
      container.name = "3 1/4 Cup Round"

      container.save!()
    end

    Container.find_or_initialize("6 Cup Flat").tap do |container|
      container.name = "6 Cup Flat"

      container.save!()
    end
  end
end