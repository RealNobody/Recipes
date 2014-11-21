module RspecFixture
  class PreSeeder
    def self.seed
    end

    def self.<=>(right_object)
      if right_object == RspecFixture::PreSeeder
        0
      else
        -1
      end
    end
  end
end