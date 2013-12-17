require "spec_helper"

shared_examples "a scrollable list controller" do
  #describe "#scrolling_list_next_link" do
  #end
  #
  #describe "#scrolling_list_previous_link" do
  #end
  #
  #parameters
  #   page
  #   per_page
  #   search
  #   id
  #   id=new
  #
  #@model_class    = self.controller_name.singularize.classify.constantize
  #@model_per_page = @model_class.default_per_page
  #@selected_item  = nil
  #@current_page   = nil

  let(:model_class) { described_class.name[0..-11].singularize.constantize }
  let(:first_page) { model_class.index_sort.page(1).to_a }
  let(:last_item) { model_class.index_sort.last }
  let(:second_page) { model_class.index_sort.page(2).to_a }
  let(:test_user) { FactoryGirl.create(:user) }
  let(:page_object) { RecipeRspecApp.current_instance.send described_class.controller_name, test_user }
  let(:scrolling_list_page) { RecipeRspecApp.current_instance.scrolling_list_page(test_user) }
  let(:action) { [:index, :page].sample }
  let(:item_action) { [:item, :edit, :show, :new_item, :new].sample }
  let(:new_attributes) { FactoryGirl.attributes_for(model_class.name.underscore.to_sym) }
  let(:show_edit) { ((rand(10) % 2) == 0) ? nil : "edit" }

  before(:each) do
    model_class.paginates_per 2
    while model_class.all.count < 20 do
      FactoryGirl.create(model_class.name.underscore.to_sym)
    end
  end

  # feature tests - no coverage, just some basic coverage of the UI.
  describe "ScrollableListController feature tests", type: :feature do
    describe "#index, #show, #edit, #new" do
      it "should show a page for a new item", :js do
        page_object.load item_id: "new"

        expect(page_object.index_list).to have_no_selected_item
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/new/
      end

      it "should default to the first item when listing the index", :js do
        page_object.load item_id: nil

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[0]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{first_page[0].id}/
      end

      it "should default to the first page of data", :js do
        page_object.load item_id: first_page[0].id, edit: show_edit

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[0]))
      end

      it "should highlight the selected item", :js do
        test_page = model_class.index_sort.page(2).to_a
        page_object.load item_id: test_page[0].id, edit: show_edit

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(test_page[0]))
        expect(page_object.index_list.list_items.first).to have_content(test_scroll_list_name(first_page[0]))
      end

      it "should start on the second page", :js do
        page_object.load({ item_id: second_page[0].id, edit: show_edit, query: { page: 2 } })

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(second_page[0]))
        expect(page_object.index_list.list_items.first).to have_content(test_scroll_list_name(second_page[0]))
      end

      it "should start on the last page", :js do
        test_page = model_class.index_sort.page(model_class.count / 2 + (model_class.count % 2) - 1).to_a
        page_object.load({ item_id: test_page[0].id, edit: show_edit, query: { page: model_class.count / 2 + (model_class.count % 2) } })

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(test_page[0]))
      end

      it "should switch selected item", :js do
        page_object.load item_id: last_item.id, edit: show_edit

        expect(page_object.index_list).to have_no_selected_item

        page_object.index_list.list_items[2].click
        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(second_page[0]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{second_page[0].id}/

        page_object.index_list.list_items[1].click
        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[1]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{first_page[1].id}/
      end
    end
  end

  describe ScrollableListController, type: :controller do
    before(:each) do
      sign_in test_user
    end

    describe "#create" do
      it "creates a new item" do
        max_id = model_class.maximum(:id)

        post :create, measuring_unit: new_attributes

        expect(response).to be_redirect
        response.should redirect_to(send("#{model_class.name.underscore}_path", assigns(:selected_item).id))
        expect(assigns(:selected_item).id).to eq(model_class.maximum(:id))
        expect(max_id).to_not eq(model_class.maximum(:id))
        expect(flash[:error]).to be_blank
      end

      it "handles a failure gracefully" do
        model_class.any_instance.stub(:save).and_return false

        max_id = model_class.maximum(:id)

        post :create, measuring_unit: new_attributes

        expect(response).to be_success
        expect(assigns(:selected_item).id).to be_blank
        expect(max_id).to eq(model_class.maximum(:id))
        expect(flash[:error]).to_not be_blank
      end
    end

    describe "#update" do
      it "should update a record" do
        expect(new_attributes[model_class.initialize_field]).to_not eq(first_page[0][model_class.initialize_field])

        patch :update,
              id:             first_page[0].id,
              measuring_unit: new_attributes

        response.should be_success
        expect(response).to render_template("index")
        expect(flash[:error]).to be_blank
      end

      it "handles a failure gracefully" do
        model_class.any_instance.stub(:save).and_return false

        expect(new_attributes[model_class.initialize_field]).to_not eq(first_page[0][model_class.initialize_field])

        patch :update,
              id:             first_page[0].id,
              measuring_unit: new_attributes

        response.should be_success
        expect(response).to render_template("index")
        expect(flash[:error]).to_not be_blank
      end
    end

    describe "#destroy" do
      let(:delete_item) { FactoryGirl.create(model_class.name.underscore.to_sym) }

      it "should delete the item if it can" do
        deleted_id = delete_item.id
        delete :destroy, id: deleted_id

        expect(response).to be_success
        expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
        expect(model_class.where(id: deleted_id).first).to_not be
        expect(response).to render_template("index")
        expect(flash[:error]).to be_blank
      end

      it "should not delete the item if it cannot" do
        model_class.any_instance.stub(:destroy).and_return false

        deleted_id = delete_item.id
        delete :destroy, id: deleted_id

        expect(response).to be_success
        expect(assigns(described_class.controller_name.singularize)).to eq(delete_item)
        expect(response).to render_template("index")
        expect(model_class.where(id: deleted_id).first).to be
        expect(flash[:error]).to_not be_empty
      end

      it "should not delete an invalid id" do
        model_class.any_instance.stub(:destroy).and_return false

        delete :destroy, id: -1

        expect(response).to be_success
        expect(assigns(described_class.controller_name.singularize).id).to be_blank
        expect(response).to render_template("index")
        expect(flash[:error]).to_not be_empty
      end
    end

    describe "json responses" do
      describe "#page or #index" do
        it "should set instance variables to defaults" do
          options        = { per_page: 2, format: "json" }
          options[:page] = 1 if action == :page

          get action, options

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(first_page)
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(described_class.controller_name).first)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(first_page[0].id)
        end

        it "should select a new item if an invalid id is passed in" do
          get action, page: 2, per_page: 2, format: "json", id: -1

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize).id).to be_blank
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should show search results" do
          options        = { per_page: 2, format: "json", search: last_item[model_class.initialize_field] }
          options[:page] = 1 if action == :page

          get action, options

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          expect(assigns(described_class.controller_name).count).to be >= 1
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(described_class.controller_name).first)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to be >= 1
          expect(json_body[0].with_indifferent_access[:id]).to eq(last_item.id)
        end

        it "should go to any page" do
          get action, page: 2, per_page: 2, format: "json"

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should assign selected_item based on id" do
          get action, page: 2, per_page: 2, format: "json", id: last_item.id

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should handle a page larger than the last page" do
          get action, page: model_class.count, per_page: 2, format: "json"

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(0)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(0)
        end
      end

      describe "#item" do
        it "should return selected_item based on id for item" do
          get item_action, page: 2, per_page: 2, format: "json", id: last_item.id

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          if [:new, :new_item].include? item_action
            expect(assigns(described_class.controller_name.singularize).id).to be_blank
          else
            expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          end
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          if [:new, :new_item].include? item_action
            expect(json_body.with_indifferent_access[:id]).to be_blank
          else
            expect(json_body.with_indifferent_access[:id]).to eq(last_item.id)
          end
        end

        it "should return a 404 if the item doesn't exist" do
          get :item, page: 2, per_page: 2, format: "json", id: -1

          expect(response).to_not be_success
        end

        it "doesn't worry about search" do
          get item_action, page: 1, per_page: 2, format: "json", id: last_item.id, search: first_page[0][model_class.initialize_field]

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

          if [:new, :new_item].include? item_action
            expect(assigns(described_class.controller_name.singularize).id).to be_blank
          else
            expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          end
          expect(assigns(described_class.controller_name).count).to be >= 1
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          if [:new, :new_item].include? item_action
            expect(json_body.with_indifferent_access[:id]).to be_blank
          else
            expect(json_body.with_indifferent_access[:id]).to eq(last_item.id)
          end
        end
      end
    end

    describe "#item" do
      it "should return selected_item based on id for item" do
        get item_action, page: 2, per_page: 2, id: last_item.id

        expect(response).to be_success

        expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
        expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
        expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

        if [:new, :new_item].include? item_action
          expect(assigns(described_class.controller_name.singularize).id).to be_blank
        else
          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
        end
        expect(assigns(described_class.controller_name).count).to eq(2)
        expect(assigns(described_class.controller_name)).to eq(second_page)
        expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
        expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

        if [:edit, :show, :new].include?(item_action)
          expect(response).to render_template("index")
        else
          expect(response).to render_template("_show")
        end
      end

      it "should return a 404 if the item doesn't exist" do
        get :item, page: 2, per_page: 2, id: -1

        expect(response).to_not be_success
      end

      it "doesn't worry about search" do
        get item_action, page: 1, per_page: 2, id: last_item.id, search: first_page[0][model_class.initialize_field]

        expect(response).to be_success

        expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_true
        expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_true
        expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_true

        if [:new, :new_item].include? item_action
          expect(assigns(described_class.controller_name.singularize).id).to be_blank
        else
          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
        end
        expect(assigns(described_class.controller_name).count).to be >= 1
        expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
        expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))

        if [:edit, :show, :new].include?(item_action)
          expect(response).to render_template("index")
        else
          expect(response).to render_template("_show")
        end
      end
    end
  end

  describe ScrollableListController, type: :request do
    describe "#page" do
      it "should return a partial page of data" do
        scrolling_list_page.load page_number: 1

        expect(scrolling_list_page).to_not have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.list_items.count).to eq 2
        expect(scrolling_list_page.list_items[0]).to have_content(test_scroll_list_name(first_page[0]))
        expect(scrolling_list_page.list_items[1]).to have_content(test_scroll_list_name(first_page[1]))
        expect(scrolling_list_page).to have_selected_item

        expect(scrolling_list_page.wait_next.find("a")[:href]).to match(/#{scrolling_list_page.url}2/)
      end

      it "should return a middle page" do
        scrolling_list_page.load page_number: 2

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.list_items.count).to eq 2
        expect(scrolling_list_page.list_items[0]).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page.list_items[1]).to have_content(test_scroll_list_name(second_page[1]))
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next.find("a")[:href]).to match(/#{scrolling_list_page.url}3/)
        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}1/)
      end

      it "should return the last page" do
        scrolling_list_page.load page_number: ((MeasuringUnit.count / 2) + (MeasuringUnit.count % 2))

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to_not have_wait_next
        expect(scrolling_list_page.list_items.count).to be >= 1
        expect(scrolling_list_page.list_items[scrolling_list_page.list_items.count - 1]).
            to have_content(test_scroll_list_name(last_item))
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}#{
        (MeasuringUnit.count / 2) + (MeasuringUnit.count % 2) - 1}/)
      end

      it "should accept a custom page_size" do
        scrolling_list_page.load page_number: 2, query: { per_page: 4 }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.list_items.count).to eq 4
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next.find("a")[:href]).to match(/#{scrolling_list_page.url}3/)
        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}1/)
      end

      it "should handle a page greater than the last page" do
        scrolling_list_page.load page_number: MeasuringUnit.count

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to_not have_wait_next
        expect(scrolling_list_page.list_items.count).to be 0
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}#{MeasuringUnit.count - 1}/)
      end

      it "should highlight the selected item" do
        scrolling_list_page.load page_number: 2, query: { id: second_page[0].id }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.list_items.count).to eq 2
        expect(scrolling_list_page.list_items[0]).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page.list_items[1]).to have_content(test_scroll_list_name(second_page[1]))
        expect(scrolling_list_page.selected_item).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page).to have_selected_item

        expect(scrolling_list_page.wait_next.find("a")[:href]).to match(/#{scrolling_list_page.url}3/)
        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}1/)
      end

      it "should page search results" do
        scrolling_list_page.load page_number: 2, query: { search: "e" }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.list_items.count).to eq 2
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next.find("a")[:href]).to match(/#{scrolling_list_page.url}3/)
        expect(scrolling_list_page.wait_previous.find("a")[:href]).to match(/#{scrolling_list_page.url}1/)
      end
    end

    #  describe "#index, #new, #show" do
    #    # page, per_page, search
    #    #page_object.load item_id: "new" # new
    #    #page_object.load item_id: first_page[0].id # show
    #    #page_object.load item_id: nil # index
    #  end
  end

  def test_scroll_list_name(class_item)
    if class_item.respond_to?(:list_name)
      class_item.send(:list_name)
    else
      if class_item.respond_to?(:name)
        class_item.send(:name)
      else
        class_item.to_s
      end
    end
  end
end