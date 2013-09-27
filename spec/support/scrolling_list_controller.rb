shared_examples "scrolling list controller" do
  #describe "#scrolling_list_next_link" do
  #end
  #
  #describe "#scrolling_list_previous_link" do
  #end

  # parameters
  #   page
  #   per_page
  #   search
  #   id
  #   id=new

  describe "#index, #show, #edit, #new" do
    it "should default to the first page of data"
    it "should return json data"
    it "should go to any page"
    it "should highlight the selected item"
    it "should show search results"
  end

  describe "#page" do
    it "should return a partial page of data"
    it "should return json data"
    it "should return a middle page"
    it "should return the last page"
    it "should handle a page greater than the last page"
    it "should highlight the selected item"
    it "should page search results"
  end

  describe "#item, #new_item" do
    it "should return 404 if an invalid item"
    it "should show an item"
    it "should return an item as json"
  end

  describe "#destroy" do
    it "should delete the item if it can"
    it "should not delete the item if it cannot"
  end

  describe "#create" do
  end

  describe "#update" do
  end
end