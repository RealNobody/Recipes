require "rails_helper"

RSpec.describe ScrollingListHelper, type: :helper do
  let(:description) { "<a>n odd & weird descrip>tion" }
  let(:link_item) { MeasuringUnit.index_sort.page(2).last }
  let(:page_items) { MeasuringUnit.index_sort.page(2) }
  let(:current_item) { MeasuringUnit.index_sort.page(2).first }
  let(:param_page) { 2 }
  let(:param_per_page) { 2 }
  let(:per_page_model) { 4 }
  let(:search_text) { "something & something = https://www.nothing?" }

  before(:each) do
    MeasuringUnit.paginates_per 2
    SearchAlias.paginates_per 2
  end

  describe "#scrolling_list_next_link" do
    define_method(:link_to_next_page) do |param_1, param_2|
      "<a href=\"http://test.host/measuring_units/8/edit?page=3\">Next Page</a>"
    end

    it "outputs a link for the next page to load" do
      test_value = scrolling_list_next_link page_items,
                                            current_item,
                                            param_page,
                                            param_per_page,
                                            per_page_model,
                                            search_text,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Next Page</a>")
    end

    it "outputs new if the current item is nil" do
      test_value = scrolling_list_next_link page_items,
                                            nil,
                                            param_page,
                                            param_per_page,
                                            per_page_model,
                                            search_text,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Next Page</a>")
    end

    it "uses the recordset page value" do
      test_value = scrolling_list_next_link page_items,
                                            current_item,
                                            22,
                                            param_per_page,
                                            per_page_model,
                                            search_text,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Next Page</a>")
    end

    it "doesn't output per page if it isn't specified" do
      test_value = scrolling_list_next_link page_items,
                                            current_item,
                                            param_page,
                                            nil,
                                            param_per_page,
                                            search_text,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Next Page</a>")
    end

    it "doesn't outputs per page if it matches the models per-page" do
      test_value = scrolling_list_next_link page_items,
                                            current_item,
                                            param_page,
                                            param_per_page,
                                            2,
                                            search_text,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Next Page</a>")
    end

    it "doesn't output the search text if not specified" do
      test_value = scrolling_list_next_link page_items,
                                            current_item,
                                            param_page,
                                            param_per_page,
                                            per_page_model,
                                            nil,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=#{current_item.id}&per_page=2\">Next Page</a>")
    end

    it "outputs a simple link if nothing is specified" do
      test_value = scrolling_list_next_link page_items,
                                            nil,
                                            nil,
                                            nil,
                                            param_per_page,
                                            nil,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=new\">Next Page</a>")
    end

    it "returns nil if it is the last page" do
      test_value = scrolling_list_next_link page_items,
                                            nil,
                                            nil,
                                            nil,
                                            8,
                                            nil,
                                            nil,
                                            nil

      expect(test_value).to_not be
    end

    it "returns id=new if it is the current item is new" do
      test_value = scrolling_list_next_link page_items,
                                            MeasuringUnit.new,
                                            nil,
                                            nil,
                                            param_per_page,
                                            nil,
                                            nil,
                                            nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/3?id=new\">Next Page</a>")
    end
  end

  describe "#scrolling_list_previous_link" do
    define_method(:link_to_previous_page) do |param_1, param_2|
      "<a href=\"http://test.host/measuring_units/8/?page=1\">Previous Page</a>"
    end

    it "outputs a link for the previous page to load" do
      test_value = scrolling_list_previous_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Previous Page</a>")
    end

    it "outputs new if the current item is nil" do
      test_value = scrolling_list_previous_link page_items,
                                                nil,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Previous Page</a>")
    end

    it "uses the recordset page value" do
      test_value = scrolling_list_previous_link page_items,
                                                current_item,
                                                22,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Previous Page</a>")
    end

    it "doesn't output per page if it isn't specified" do
      test_value = scrolling_list_previous_link page_items,
                                                current_item,
                                                param_page,
                                                nil,
                                                param_per_page,
                                                search_text,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Previous Page</a>")
    end

    it "doesn't outputs per page if it matches the models per-page" do
      test_value = scrolling_list_previous_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                2,
                                                search_text,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">Previous Page</a>")
    end

    it "doesn't output the search text if not specified" do
      test_value = scrolling_list_previous_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                nil,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=#{current_item.id}&per_page=2\">Previous Page</a>")
    end

    it "outputs a simple link if nothing is specified" do
      test_value = scrolling_list_previous_link page_items,
                                                nil,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=new\">Previous Page</a>")
    end

    it "returns nil if it is the last page" do
      test_value = scrolling_list_previous_link MeasuringUnit.page(1),
                                                nil,
                                                nil,
                                                nil,
                                                per_page_model,
                                                nil,
                                                nil,
                                                nil

      expect(test_value).to_not be
    end

    it "outputs id=new if current_item is new" do
      test_value = scrolling_list_previous_link page_items,
                                                MeasuringUnit.new,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                nil,
                                                nil

      expect(test_value).to eq("<a href=\"http://test.host/measuring_units/page/1?id=new\">Previous Page</a>")
    end
  end

  describe "#scroll_list_name" do
    it "outputs the #list_name" do
      mock_model = double :mock_model, list_name: "list_name", name: "name", to_s: "to_s"
      expect(scroll_list_name(mock_model)).to eq("list_name")
    end

    it "outputs the #name" do
      mock_model = double :mock_model, name: "name", to_s: "to_s"
      expect(scroll_list_name(mock_model)).to eq("name")
    end

    it "outputs the #to_s" do
      mock_model = double :mock_model, to_s: "to_s"
      expect(scroll_list_name(mock_model)).to eq("to_s")
    end
  end

  describe "#scrolling_list_link_to_item" do
    it "outputs a full link" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "doesn't care about the page_items" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               nil,
                                               current_item,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "doesn't care about the current_item" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               nil,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "makes the item active if the current_item == link_item" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               link_item,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li class=\"active\"><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{link_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "allows param_page to be nil" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               nil,
                                               param_per_page,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "allows param_per_page to be nil" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               param_page,
                                               nil,
                                               per_page_model,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "does not output per_page if it matches per_page_model" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               param_page,
                                               param_per_page,
                                               param_per_page,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "allows per_page_model to be nil" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               param_page,
                                               param_per_page,
                                               nil,
                                               search_text,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "does not require search text" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               current_item,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               nil,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&id=#{current_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "handles a new current_item" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               page_items,
                                               MeasuringUnit.new,
                                               param_page,
                                               param_per_page,
                                               per_page_model,
                                               nil,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}?page=2&per_page=2&id=new\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end

    it "outputs a basic link with minimal information" do
      test_value = scrolling_list_link_to_item description,
                                               link_item,
                                               nil,
                                               nil,
                                               nil,
                                               nil,
                                               nil,
                                               nil,
                                               nil,
                                               nil

      expect(test_value).to eq("<li><a class=\"scroll-item-link\" href=\"/measuring_units/#{link_item.id}\">&lt;a&gt;n odd &amp; weird descrip&gt;tion</a></li>")
    end
  end

  describe "page title" do
    let(:selected_item) { FactoryGirl.create(:measuring_unit) }

    before(:each) do
      instance_variable_set("@model_class", MeasuringUnit)
      instance_variable_set("@selected_item", selected_item)
    end

    describe "#page_title_field" do
      it "should return a hidden tag" do
        expect(page_title_field).to eq(hidden_field_tag("measuring_units-title", "#{selected_item.list_name} - Measuring Unit | Recipes"))
      end
    end

    describe "#page_title" do
      it "should return a base title if no model class" do
        instance_variable_set("@model_class", nil)
        expect(page_title).to eq("Recipes")
      end

      it "should return a default title" do
        expect(page_title).to eq("#{selected_item.list_name} - Measuring Unit | Recipes")
      end

      it "should use scroll_list_name" do
        allow(selected_item).to receive(:list_name).and_return("Erik")
        expect(page_title).to eq("Erik - Measuring Unit | Recipes")
      end

      it "use a custom format if specified" do
        allow(selected_item).to receive(:list_name).and_return("Erik")
        expect(page_title).to eq("Erik - Measuring Unit | Recipes")
      end
    end
  end

  context "paging a child object" do
    context "simple relationship" do
      let(:parent_item) { MeasuringUnit.find_by_alias("Fluid-Ounce") }
      let(:page_items) { parent_item.search_aliases.index_sort.page(2) }
      let(:current_item) { parent_item.search_aliases.index_sort.page(2).first }
      let(:param_page) { 2 }
      let(:param_per_page) { 2 }
      let(:per_page_model) { 4 }

      describe "#scrolling_list_next_link" do
        it "outputs a link for the next page to load" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "outputs new if the current item is nil" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "uses the recordset page value" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                22,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "doesn't output per page if it isn't specified" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                nil,
                                                param_per_page,
                                                search_text,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "doesn't outputs per page if it matches the models per-page" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                2,
                                                search_text,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "doesn't output the search text if not specified" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                nil,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=#{current_item.id}&per_page=2\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "outputs a simple link if nothing is specified" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end

        it "returns nil if it is the last page" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                nil,
                                                nil,
                                                8,
                                                nil,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to_not be
        end

        it "returns id=new if it is the current item is new" do
          test_value = scrolling_list_next_link page_items,
                                                MeasuringUnit.new,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                parent_item,
                                                :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/3?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Next Page</a>")
        end
      end

      describe "#scrolling_list_previous_link" do
        it "outputs a link for the previous page to load" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "outputs new if the current item is nil" do
          test_value = scrolling_list_previous_link page_items,
                                                    nil,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "uses the recordset page value" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    22,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "doesn't output per page if it isn't specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    nil,
                                                    param_per_page,
                                                    search_text,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "doesn't outputs per page if it matches the models per-page" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    2,
                                                    search_text,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "doesn't output the search text if not specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    nil,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=#{current_item.id}&per_page=2\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "outputs a simple link if nothing is specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    nil,
                                                    nil,
                                                    nil,
                                                    param_per_page,
                                                    nil,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end

        it "returns nil if it is the last page" do
          test_value = scrolling_list_previous_link MeasuringUnit.page(1),
                                                    nil,
                                                    nil,
                                                    nil,
                                                    per_page_model,
                                                    nil,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to_not be
        end

        it "outputs id=new if current_item is new" do
          test_value = scrolling_list_previous_link page_items,
                                                    MeasuringUnit.new,
                                                    nil,
                                                    nil,
                                                    param_per_page,
                                                    nil,
                                                    parent_item,
                                                    :search_aliases

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/search_aliases/page/1?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_search_aliases&quot;}\">Previous Page</a>")
        end
      end
    end

    context "through relationship" do
      let(:parent_item) { MeasuringUnit.find_by_alias("Milliliter") }
      let(:page_items) { parent_item.larger_measurement_conversions.index_sort.page(2).per(2) }
      let(:current_item) { parent_item.larger_measurement_conversions.index_sort.page(2).per(2).first }
      let(:param_page) { 2 }
      let(:param_per_page) { 2 }
      let(:per_page_model) { 4 }

      describe "#scrolling_list_next_link" do
        it "outputs a link for the next page to load" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "outputs new if the current item is nil" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "uses the recordset page value" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                22,
                                                param_per_page,
                                                per_page_model,
                                                search_text,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "doesn't output per page if it isn't specified" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                nil,
                                                param_per_page,
                                                search_text,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "doesn't outputs per page if it matches the models per-page" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                2,
                                                search_text,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "doesn't output the search text if not specified" do
          test_value = scrolling_list_next_link page_items,
                                                current_item,
                                                param_page,
                                                param_per_page,
                                                per_page_model,
                                                nil,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=#{current_item.id}&per_page=2\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "outputs a simple link if nothing is specified" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end

        it "returns nil if it is the last page" do
          test_value = scrolling_list_next_link page_items,
                                                nil,
                                                nil,
                                                nil,
                                                8,
                                                nil,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to_not be
        end

        it "returns id=new if it is the current item is new" do
          test_value = scrolling_list_next_link page_items,
                                                MeasuringUnit.new,
                                                nil,
                                                nil,
                                                param_per_page,
                                                nil,
                                                parent_item,
                                                :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/3?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Next Page</a>")
        end
      end

      describe "#scrolling_list_previous_link" do
        it "outputs a link for the previous page to load" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "outputs new if the current item is nil" do
          test_value = scrolling_list_previous_link page_items,
                                                    nil,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=new&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "uses the recordset page value" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    22,
                                                    param_per_page,
                                                    per_page_model,
                                                    search_text,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=#{current_item.id}&per_page=2&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "doesn't output per page if it isn't specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    nil,
                                                    param_per_page,
                                                    search_text,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "doesn't outputs per page if it matches the models per-page" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    2,
                                                    search_text,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=#{current_item.id}&search=something%20%26%20something%20%3D%20https%3A%2F%2Fwww.nothing%3F\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "doesn't output the search text if not specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    current_item,
                                                    param_page,
                                                    param_per_page,
                                                    per_page_model,
                                                    nil,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=#{current_item.id}&per_page=2\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "outputs a simple link if nothing is specified" do
          test_value = scrolling_list_previous_link page_items,
                                                    nil,
                                                    nil,
                                                    nil,
                                                    param_per_page,
                                                    nil,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end

        it "returns nil if it is the last page" do
          test_value = scrolling_list_previous_link MeasuringUnit.page(1),
                                                    nil,
                                                    nil,
                                                    nil,
                                                    per_page_model,
                                                    nil,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to_not be
        end

        it "outputs id=new if current_item is new" do
          test_value = scrolling_list_previous_link page_items,
                                                    MeasuringUnit.new,
                                                    nil,
                                                    nil,
                                                    param_per_page,
                                                    nil,
                                                    parent_item,
                                                    :larger_measurement_conversions

          expect(test_value).to eq("<a href=\"http://test.host/measuring_units/#{parent_item.id}/larger_measurement_conversions/page/1?id=new\" params=\"{:use_route=&gt;&quot;measuring_unit_larger_measurement_conversions&quot;}\">Previous Page</a>")
        end
      end
    end
  end
end