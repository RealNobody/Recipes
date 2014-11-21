module RspecFixture
  class PreCleaner
    def initialize(start_function, end_function, table, options = {})
    end

    def suite_start
    end

    def <=>(right_object)
      if right_object.class == RspecFixture::PreCleaner
        0
      else
        -1
      end
    end
  end
end