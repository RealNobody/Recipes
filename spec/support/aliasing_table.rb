shared_examples "an aliasing table" do
  it { should_respond_to(:alias) }
  it "should_respond_to(\"\#{aliased_table.to_s}_id\".to_sym)"
  # it { should_respond_to(:index_sort) }
  it { should_respond_to(:list_name) }

  describe "validations" do
    it "should require an \#{aliased_table}"
    it "should require an alias"
    it "should not allow an alias larger than 255"
    it "should require alias to be unique"
    it "should allow a blank alias if appropriate"
    it "should not allow a blank alias if appropriate"
    it "should prevent deleting default aliases if appropriate"
    it "should allow deleting default aliases if appropriate"
  end

  describe "#alias" do
    it "should be able to read the value of alias"
    it "should downcase alias when it is set"
  end
end