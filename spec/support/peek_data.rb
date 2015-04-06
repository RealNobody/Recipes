RSpec.configure do |config|
  def peek_data(failure_description)
    review_data = {}

    PseudoCleaner::MasterCleaner.review_rows do |table, row|
      review_data[table] ||= []
      review_data[table] << row
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
  end

  config.after(:each) do |example|
    # Difference between RSPEC 2 and RSPEC 3
    example = example.example if example.respond_to?(:example)

    if (example.exception)
      peek_data example.full_description
    end
  end
end