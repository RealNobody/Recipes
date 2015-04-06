require "singleton"

class ValidationHistory
  include Singleton

  attr_accessor :review_data_history

  def initialize
    @review_data_history = {}
  end

  def review_row(table, row)
    review_data_history[table] ||= {}

    unless review_data_history[table][row["id"]]
      review_data_history[table][row["id"]] = true
      row
    end
  end
end

if $recipes_validate_data
  RSpec.configure do |config|
    def validate_data(failure_description)
      review_data = {}

      PseudoCleaner::MasterCleaner.review_rows do |table, row|
        add_row = ValidationHistory.instance.review_row(table, row)

        if add_row
          review_data[table] ||= []
          review_data[table] << row
        end
      end

      unless review_data.empty?
        Cornucopia::Util::ReportBuilder.current_report.
            within_section("Data for #{failure_description}") do |report|
          report.within_hidden_table do |outer_report_table|
            review_data.each do |table_name, rows|
              Cornucopia::Util::ReportTable.new(
                  report_table:         nil,
                  nested_table:         outer_report_table,
                  suppress_blank_table: true) do |sub_tables|
                Cornucopia::Util::ReportTable.new(
                    report_table:         nil,
                    nested_table:         sub_tables,
                    nested_table_label:   table_name,
                    suppress_blank_table: true) do |report_table|
                  rows.each_with_index do |row, row_index|
                    report_table.write_stats row_index.to_s, row
                  end
                end
              end
            end
          end
        end
      end

      expect(review_data.empty?).to be_truthy
    end

    config.after(:each) do |example|
      unless example.metadata[:skip_validate]
        validate_data example.full_description
      end
    end
  end
end