class Seedling
  @@create_order = nil

  class << self
    def seed_all
      Seedling.create_order.each do |table|
        Seedling.seed(table)
      end
    end

    def seed(table)
      if table && table.respond_to?(:seed)
        table.send :seed
      end
    end

    def test_start
      Seedling.new :test_start, :test_end
    end

    def suite_start
      Seedling.new :suite_start, :suite_end
    end

    def create_order
      unless @@create_order
        @@create_order = []
        ActiveRecord::Base.connection.tables.each do |table_name|
          table = nil
          begin
            table = table_name.to_s.singularize.classify.constantize
          rescue NameError
            # ignore, we don't care about tables we don't have classes for
          end

          if table
            prev_table = pre_table(table)
            while (prev_table)
              @@create_order << prev_table
              prev_table = pre_table(table)
            end

            @@create_order << table unless @@create_order.include?(table)
          end
        end
      end

      @@create_order
    end

    def pre_table(table)
      prev_table = nil

      relations = table.reflect_on_all_associations(:belongs_to)
      relations.each do |belongs_to|
        belongs_to_table_name = belongs_to.options[:class_name] || belongs_to.name
        prev_table            = belongs_to_table_name.to_s.singularize.classify.constantize

        if @@create_order.include?(prev_table)
          prev_table = nil
        else
          prev_table = pre_table(prev_table) || prev_table
        end

        break if prev_table
      end

      prev_table
    end
  end

  def initialize(start_method, end_method, table = nil)
    @start_method = start_method
    @end_method   = end_method

    if table
      @table = table
      self.send @start_method
    else
      @seedlings = []

      Seedling.create_order.each do |table|
        @seedlings << Seedling.new(@start_method, @end_method, table)
      end
    end
  end

  def test_start
    if @table
      if @table.respond_to?(@start_method)
        @max_id = @table.send @start_method
      else
        if @table.columns.find { |column| column.name == "id" }
          @max_id = @table.maximum(:id)
        end
      end
    end
  end

  def test_end
    # we should check the relationships for any records which still refer to
    # a now deleted record.  (i.e. if we updated a record to refer to a record)
    # we deleted...
    #
    # Which is why this is not a common or particularly good solution.
    #
    # I'm using it because it is faster than reseeding each test...
    # And, I can be responsible for worrying about referential integrity in the test
    # if I want to...
    if @table
      puts("  Resetting table \"#{@table.name}\"...") if @output_diagnostics

      if @table.respond_to?(@start_method)
        if @table.respond_to?(@end_method)
          @table.send(@end_method, @max_id)
        end
      else
        if @table.columns.find { |column| column.name == "id" }
          the_max = @max_id || 0
          @table.where("id > :id", id: the_max).delete_all
        end
      end
    else
      puts("Resetting tables...") if @output_diagnostics

      index = @seedlings.length - 1
      while index >= 0
        @seedlings[index].send(@end_method)
        index -= 1
      end

      puts("Done") if @output_diagnostics
    end
  end

  alias_method :suite_start, :test_start
  alias_method :suite_end, :test_end
end