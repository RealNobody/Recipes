shared_examples "an aliased table" do
  describe "#create" do
    it "should create automatic aliases on save"
    it "should create automatic pleural aliases on save"
    it "should not allow a new record with an existing alias"
    it "should not allow a new record with an existing alias case insensitive"
  end

  describe "##{subject.class}.find_by_alias" do
    it "should find an alias record exact match"
    it "should find an alias record exact match case insensitive"
    it "should not search for nil"
  end

  describe "#add_alias" do
    it "should not add an alias that is an alias for another item"
    it "should add an alias that is not already in the list of aliases for the item (not saved)"
    it "should return an already existing alias"
  end

  describe "##{subject.class}.find_or_initialize" do
    it "should initialize an object if it cannot be found"
    it "should find an object with an exact match"
    it "should find an object with an exact match case insensitive"
    it "should find an object by an alias"
    it "should find an object by an alias case insensitive"
  end

  describe "##{subject.class}.search_alias" do
    it "should return everything if empty string passed"
    it "should find an exact match"
    it "should find a mixed-up match"
    it "should prefer an exact match"

    # not very i18n, but for now it is OK.
    it "should ignore punctuation and non alpha numeric characters"

    it "should ignore small words < 2"
  end

  describe "#is_default_alias" do
    it "should return true if the alias is a default alias"
    it "should return true if the alias is a default pleural alias"
    it "should return false if the alias is not a default alias"
  end
end