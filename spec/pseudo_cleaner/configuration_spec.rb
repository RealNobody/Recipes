require "rails_helper"

RSpec.describe PseudoCleaner::Configuration do
  it "always has a #current_instance" do
    config = PseudoCleaner::Configuration.current_instance
    expect(config).to be
    expect(config.__id__).to eq PseudoCleaner::Configuration.current_instance.__id__
  end

  describe "#output_diagnostics" do
    it "defaults output_diagnostics to false" do
      expect(PseudoCleaner::Configuration.current_instance.output_diagnostics).to be_falsey
    end

    it "sets output_diagnostics" do
      expect(PseudoCleaner::Configuration.current_instance.output_diagnostics).to be_falsey
      PseudoCleaner::Configuration.current_instance.output_diagnostics = true
      expect(PseudoCleaner::Configuration.current_instance.output_diagnostics).to be_truthy
      PseudoCleaner::Configuration.current_instance.output_diagnostics = false
      expect(PseudoCleaner::Configuration.current_instance.output_diagnostics).to be_falsey
    end
  end

  describe "#clean_database_before_tests" do
    it "defaults clean_database_before_tests to false" do
      expect(PseudoCleaner::Configuration.current_instance.clean_database_before_tests).to be_falsey
    end

    it "sets clean_database_before_tests" do
      expect(PseudoCleaner::Configuration.current_instance.clean_database_before_tests).to be_falsey
      PseudoCleaner::Configuration.current_instance.clean_database_before_tests = true
      expect(PseudoCleaner::Configuration.current_instance.clean_database_before_tests).to be_truthy
      PseudoCleaner::Configuration.current_instance.clean_database_before_tests = false
      expect(PseudoCleaner::Configuration.current_instance.clean_database_before_tests).to be_falsey
    end
  end

  describe "#reset_auto_increment" do
    it "defaults reset_auto_increment to false" do
      expect(PseudoCleaner::Configuration.current_instance.reset_auto_increment).to be_truthy
    end

    it "sets reset_auto_increment" do
      expect(PseudoCleaner::Configuration.current_instance.reset_auto_increment).to be_truthy
      PseudoCleaner::Configuration.current_instance.reset_auto_increment = false
      expect(PseudoCleaner::Configuration.current_instance.reset_auto_increment).to be_falsey
      PseudoCleaner::Configuration.current_instance.reset_auto_increment = true
      expect(PseudoCleaner::Configuration.current_instance.reset_auto_increment).to be_truthy
    end
  end

  describe "#single_cleaner_set" do
    it "defaults single_cleaner_set to true" do
      expect(PseudoCleaner::Configuration.current_instance.single_cleaner_set).to be_truthy
    end

    it "sets single_cleaner_set" do
      expect(PseudoCleaner::Configuration.current_instance.single_cleaner_set).to be_truthy
      PseudoCleaner::Configuration.current_instance.single_cleaner_set = false
      expect(PseudoCleaner::Configuration.current_instance.single_cleaner_set).to be_falsey
      PseudoCleaner::Configuration.current_instance.single_cleaner_set = true
      expect(PseudoCleaner::Configuration.current_instance.single_cleaner_set).to be_truthy
    end
  end
end