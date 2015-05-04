require "rails_helper"

RSpec.shared_examples "a scrollable list controller" do
  let(:model_class) { described_class.name[0..-11].singularize.constantize }
  let(:first_page) { model_class.index_sort.page(1).to_a }
  let(:last_item) { model_class.index_sort.last }
  let(:second_page) { model_class.index_sort.page(2).to_a }
  let(:test_user) { FactoryGirl.create(:user) }
  let(:page_object) { RecipeRspecApp.full_page(test_user, model_class) }
  let(:scrolling_list_page) { RecipeRspecApp.scrolling_list_page(test_user, model_class) }
  let(:action) { [:index, :page].sample }
  let(:new_attributes) { FactoryGirl.attributes_for(model_class.name.underscore.to_sym) }
  let(:show_edit) { ((rand(10) % 2) == 0) ? nil : "edit" }

  before(:each) do
    model_class.paginates_per 2
    while model_class.count < 20 do
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
        expect(page_object.page_name.text).
            to eq described_class.controller_name.classify.constantize.model_name.human.pluralize.titleize
      end

      it "should default to the first item when listing the index", :js do
        page_object.load item_id: nil

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[0]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{first_page[0].id}/
        expect(page_object.page_name.text).
            to eq described_class.controller_name.classify.constantize.model_name.human.pluralize.titleize
      end

      it "should default to the first page of data", :js do
        page_object.load item_id: first_page[0].id, edit: show_edit

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[0]))
        expect(page_object.page_name.text).
            to eq described_class.controller_name.classify.constantize.model_name.human.pluralize.titleize
      end

      it "should highlight the selected item", :js do
        test_page = model_class.index_sort.page(2).to_a
        page_object.load item_id: test_page[0].id, edit: show_edit

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(test_page[0]))
        expect(page_object.index_list.items.first).to have_content(test_scroll_list_name(first_page[0]))
        expect(page_object.page_name.text).
            to eq described_class.controller_name.classify.constantize.model_name.human.pluralize.titleize
      end

      it "should start on the second page", :js do
        page_object.load({ item_id: second_page[0].id, edit: show_edit, query: { page: 2 } })

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(second_page[0]))

        # # This shoul be true initially, but as the page loads, it could become not true.
        # # This should be a sufficient test.  We have other non-feature tests to test the rest of the stuff.
        # expect(page_object.index_list.items.first).to have_content(test_scroll_list_name(second_page[0]))
      end

      it "should start on the last page", :js do
        test_page = model_class.index_sort.page(model_class.count / 2 + (model_class.count % 2) - 1).to_a
        page_object.load({ item_id: test_page[0].id, edit: show_edit, query: { page: model_class.count / 2 + (model_class.count % 2) } })

        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(test_page[0]))
      end

      it "should switch selected item", :js do
        page_object.load item_id: last_item.id, edit: show_edit

        expect(page_object.index_list).to have_no_selected_item

        page_object.index_list.items[2].click
        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(second_page[0]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{second_page[0].id}/

        page_object.index_list.items[1].click
        expect(page_object.index_list.selected_item).to have_content(test_scroll_list_name(first_page[1]))
        expect(page_object.current_url).to match /\/#{described_class.controller_name}\/#{first_page[1].id}/
      end
    end
  end

  describe "ScrollableListController", type: :controller do
    before(:each) do
      sign_in test_user
    end

    parent_relations = []

    temp_model_class = described_class.name[0..-11].singularize.constantize
    (temp_model_class.reflect_on_all_associations(:belongs_to) +
        temp_model_class.reflect_on_all_associations(:has_and_belongs_to_many)).
        each do |belongs_to|
      if belongs_to.options[:polymorphic]
        ActiveRecord::Base.connection.tables.map do |table_name|
          if Object.const_defined?(table_name.classify, false)
            parent_class     = table_name.classify.constantize
            parent_relations |= parent_class.reflect_on_all_associations(:has_many).select do |has_many|
              has_many.klass == temp_model_class
            end
          end
        end
      else
        parent_relations |= belongs_to.klass.reflect_on_all_associations(:has_many).select do |has_many|
          has_many.klass == temp_model_class
        end
        parent_relations |= belongs_to.klass.reflect_on_all_associations(:has_and_belongs_to_many).select do |has_many|
          has_many.klass == temp_model_class
        end
      end
    end

    parent_relations.each do |parent_relation|
      describe "child index page for #{parent_relation.active_record.name}" do
        let(:parent_obj) { FactoryGirl.create(parent_relation.active_record.name.underscore.to_sym) }
        let(:not_parent_obj) { FactoryGirl.create(parent_relation.active_record.name.underscore.to_sym) }
        let(:child_obj) { parent_obj.send(parent_relation.plural_name).to_a.sample }

        before(:each) do
          relationship = parent_relation
          if (parent_relation.is_a?(ActiveRecord::Reflection::ThroughReflection))
            relationship = parent_relation.through_reflection
          end

          parent_relation.class_name.constantize.paginates_per 2

          # ensure that there are enough child objects
          has_many_table_name = relationship.class_name.constantize.name
          foreign_key         = relationship.foreign_key.to_sym

          while parent_obj.send(parent_relation.plural_name).count < 2 do
            if parent_relation.macro == :has_and_belongs_to_many
              relation_name = parent_relation.plural_name

              if (parent_relation.options[:join_table])
                has_many_table_name = parent_relation.options[:join_table].to_s.classify.constantize.name
                fk_field            = parent_relation.options[:foreign_key]

                child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym, fk_field => parent_obj.id)
                child_object.save

                child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym, fk_field => not_parent_obj.id)
                child_object.save
              else
                child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym)
                child_object.save
                parent_obj.send(relation_name) << child_object

                child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym)
                child_object.save
                not_parent_obj.send(relation_name) << child_object
              end
            else
              FactoryGirl.build(has_many_table_name.underscore.to_sym, foreign_key => parent_obj.id).save
              FactoryGirl.build(has_many_table_name.underscore.to_sym, foreign_key => not_parent_obj.id).save
            end
          end
        end

        it "generates a child index page" do
          attributes                                           = {}
          attributes["#{parent_obj.class.name.underscore}_id"] = parent_obj.id
          attributes[:id]                                      = child_obj.id

          get :item, attributes
          expect(response).to be_success
        end

        it "generates a child new page for #{parent_relation.active_record.name}" do
          attributes                                           = {}
          attributes["#{parent_obj.class.name.underscore}_id"] = parent_obj.id

          get :new_item, attributes
          expect(response).to be_success
        end
      end
    end

    describe "#create" do
      it "creates a new item" do
        new_attributes

        max_id = model_class.maximum(:id)

        post :create, model_class.name.underscore => new_attributes

        expect(response).to be_redirect
        expect(response).to redirect_to(send("#{model_class.name.underscore}_path", assigns(:selected_item).id))
        expect(assigns(:selected_item).id).to eq(model_class.maximum(:id))
        expect(max_id).to_not eq(model_class.maximum(:id))
        expect(flash[:error]).to be_blank
      end

      it "handles a failure gracefully" do
        allow(subject).to receive(:permitted_attributes) do |params|
          if params.respond_to? (:permit)
            params = params.permit(params.first)
          end

          params
        end

        new_attributes[model_class.initialize_field] = nil

        max_id = model_class.maximum(:id)
        post :create, model_class.name.underscore => new_attributes

        expect(response).to be_success
        expect(assigns(:selected_item).id).to be_blank
        expect(max_id).to eq(model_class.maximum(:id))
        expect(flash[:error]).to_not be_blank
      end

      it "handles an unknown failure gracefully" do
        allow_any_instance_of(model_class).to receive(:save).and_return false

        max_id = model_class.maximum(:id)
        post :create, model_class.name.underscore => new_attributes

        expect(response).to be_success
        expect(assigns(:selected_item).id).to be_blank
        expect(flash[:error]).to_not be_blank
      end
    end

    describe "#update" do
      it "should update a record" do
        expect(new_attributes[model_class.initialize_field]).to_not eq(first_page[0][model_class.initialize_field])

        patch :update,
              id:                         first_page[0].id,
              model_class.name.underscore => new_attributes

        expect(response).to be_success
        expect(response).to render_template("index")
        expect(flash[:error]).to be_blank
      end

      it "handles a failure gracefully" do
        new_attributes[model_class.initialize_field] = nil
        expect(new_attributes[model_class.initialize_field]).to_not eq(first_page[0][model_class.initialize_field])

        patch :update,
              id:                         first_page[0].id,
              model_class.name.underscore => new_attributes

        expect(response).to be_success
        expect(response).to render_template("index")
        expect(flash[:error]).to_not be_blank
      end

      it "handles an unknown failure gracefully" do
        allow_any_instance_of(model_class).to receive(:save).and_return false

        patch :update,
              id:                         first_page[0].id,
              model_class.name.underscore => new_attributes

        expect(response).to be_success
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
        allow_any_instance_of(model_class).to receive(:destroy).and_return false

        deleted_id = delete_item.id
        delete :destroy, id: deleted_id

        expect(response).to be_success
        expect(assigns(described_class.controller_name.singularize)).to eq(delete_item)
        expect(response).to render_template("index")
        expect(model_class.where(id: deleted_id).first).to be
        expect(flash[:error]).to_not be_empty
      end

      it "should not delete an invalid id" do
        allow_any_instance_of(model_class).to receive(:destroy).and_return false

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

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(first_page)
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(described_class.controller_name).first)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(first_page[0].id)
        end

        it "should select a new item if an invalid id is passed in" do
          get action, page: 2, per_page: 2, format: "json", id: -1

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize).id).to be_blank
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should go to any page" do
          get action, page: 2, per_page: 2, format: "json"

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should assign selected_item based on id" do
          get action, page: 2, per_page: 2, format: "json", id: last_item.id

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          expect(assigns(described_class.controller_name).count).to eq(2)
          expect(assigns(described_class.controller_name)).to eq(second_page)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(2)
          expect(json_body[0].with_indifferent_access[:id]).to eq(second_page[0].id)
        end

        it "should handle a page larger than the last page" do
          get action, page: model_class.count, per_page: 2, format: "json"

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize)).to eq(first_page[0])
          expect(assigns(described_class.controller_name).count).to eq(0)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to eq(0)
        end
      end

      [:item, :edit, :show, :new_item, :new].each do |item_action|
        describe "##{item_action}" do
          it "should return selected_item based on id for item" do
            get item_action, page: 2, per_page: 2, format: "json", id: last_item.id

            expect(response).to be_success

            expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

            if [:new, :new_item].include? item_action
              expect(assigns(described_class.controller_name.singularize).id).to be_blank
            else
              expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
            end
            expect(assigns(described_class.controller_name).count).to eq(2)
            expect(assigns(described_class.controller_name)).to eq(second_page)
            expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
            expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
            expect(assigns(:parent_obj)).to_not be
            expect(assigns(:parent_relationship)).to_not be
            expect(assigns(:parent_ref_field)).to_not be

            expect(response.content_type).to eq("application/json")
            json_body = JSON.parse(response.body)
            if [:new, :new_item].include? item_action
              expect(json_body.with_indifferent_access[:id]).to be_blank
            else
              expect(json_body.with_indifferent_access[:id]).to eq(last_item.id)
            end
          end

          it "should return selected_item based on id for item" do
            get item_action, page: 2, per_page: 2, id: last_item.id

            expect(response).to be_success

            expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

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

          it "doesn't worry about search" do
            get item_action, page: 1, per_page: 2, format: "json", id: last_item.id, search: first_page[0][model_class.initialize_field]

            expect(response).to be_success

            expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

            if [:new, :new_item].include? item_action
              expect(assigns(described_class.controller_name.singularize).id).to be_blank
            else
              expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
            end
            expect(assigns(described_class.controller_name).count).to be >= 1
            expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
            expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
            expect(assigns(:parent_obj)).to_not be
            expect(assigns(:parent_relationship)).to_not be
            expect(assigns(:parent_ref_field)).to_not be

            expect(response.content_type).to eq("application/json")
            json_body = JSON.parse(response.body)
            if [:new, :new_item].include? item_action
              expect(json_body.with_indifferent_access[:id]).to be_blank
            else
              expect(json_body.with_indifferent_access[:id]).to eq(last_item.id)
            end
          end

          it "doesn't worry about search not json" do
            get item_action, page: 1, per_page: 2, id: last_item.id, search: first_page[0][model_class.initialize_field]

            expect(response).to be_success

            expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
            expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

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
    end

    describe "#item" do
      it "should return a 404 if the item doesn't exist" do
        get :item, page: 2, per_page: 2, id: -1

        expect(response).to_not be_success
      end
    end
  end

  # describe "ScrollingListHelper", type: :helper do
  #   #@model_class    = self.controller_name.classify.constantize
  #   #@model_per_page = @model_class.default_per_page
  #   #@selected_item  = nil
  #   #@current_page   = nil
  #
  #   #describe "#scrolling_list_next_link" do
  #   #end
  #   #
  #   #describe "#scrolling_list_previous_link" do
  #   #end
  # end

  describe "ScrollableListController", type: :request do
    describe "#page" do
      it "should return a partial page of data" do
        scrolling_list_page.load page_number: 1

        expect(scrolling_list_page).to_not have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.items.count).to eq 2
        expect(scrolling_list_page.items[0]).to have_content(test_scroll_list_name(first_page[0]))
        expect(scrolling_list_page.items[1]).to have_content(test_scroll_list_name(first_page[1]))
        expect(scrolling_list_page).to have_selected_item

        expect(scrolling_list_page.wait_next[:href]).to match(/#{scrolling_list_page.url page_number: 2}/)
      end

      it "should return a middle page" do
        scrolling_list_page.load page_number: 2

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.items.count).to eq 2
        expect(scrolling_list_page.items[0]).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page.items[1]).to have_content(test_scroll_list_name(second_page[1]))
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next[:href]).to match(/#{scrolling_list_page.url page_number: 3}/)
        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: 1}/)
      end

      it "should return the last page" do
        scrolling_list_page.load page_number: ((model_class.count / 2) + (model_class.count % 2))

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to_not have_wait_next
        expect(scrolling_list_page.items.count).to be >= 1
        expect(scrolling_list_page.items[scrolling_list_page.items.count - 1]).
            to have_content(test_scroll_list_name(last_item))
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: (model_class.count / 2) + (model_class.count % 2) - 1}/)
      end

      it "should accept a custom page_size" do
        scrolling_list_page.load page_number: 2, query: { per_page: 4 }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.items.count).to eq 4
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next[:href]).to match(/#{scrolling_list_page.url page_number: 3}/)
        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: 1}/)
      end

      it "should handle a page greater than the last page" do
        scrolling_list_page.load page_number: model_class.count

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to_not have_wait_next
        expect(scrolling_list_page.items.count).to be 0
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: model_class.count - 1}/)
      end

      it "should highlight the selected item" do
        scrolling_list_page.load page_number: 2, query: { id: second_page[0].id }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.items.count).to eq 2
        expect(scrolling_list_page.items[0]).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page.items[1]).to have_content(test_scroll_list_name(second_page[1]))
        expect(scrolling_list_page.selected_item).to have_content(test_scroll_list_name(second_page[0]))
        expect(scrolling_list_page).to have_selected_item

        expect(scrolling_list_page.wait_next[:href]).to match(/#{scrolling_list_page.url page_number: 3}/)
        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: 1}/)
      end

      it "should page search results" do
        # TODO:  Is this reliable enough?  Can we/Should we make this better?
        scrolling_list_page.load page_number: 2, query: { search: "e" }

        expect(scrolling_list_page).to have_wait_previous
        expect(scrolling_list_page).to have_wait_next
        expect(scrolling_list_page.items.count).to eq 2
        expect(scrolling_list_page).to_not have_selected_item

        expect(scrolling_list_page.wait_next[:href]).to match(/#{scrolling_list_page.url page_number: 3}/)
        expect(scrolling_list_page.wait_previous[:href]).to match(/#{scrolling_list_page.url page_number: 1}/)
      end

      it "should self-paginate" do
        prev_scroll_link = nil
        page_loop        = 1
        prev_page_loop   = 0
        next_scroll_link = nil
        page_size        = model_class.count / 4
        page_size        = rand((page_size / 2)..page_size)

        scrolling_list_page.load page_number: 1, query: { per_page: page_size }

        expect(scrolling_list_page).to have_no_wait_previous
        expect(scrolling_list_page.wait_next).to be

        begin
          prev_scroll_link = scrolling_list_page.wait_previous[:href] unless scrolling_list_page.has_no_wait_previous?
          if (prev_scroll_link)
            expect(scrolling_list_page.displayed?).to be_truthy
            expect(prev_scroll_link).to(match(/\/page\/#{prev_page_loop}\?/))
          end

          prev_page_loop += 1
          page_loop      += 1

          if scrolling_list_page.has_no_wait_next?
            next_scroll_link = nil
          else
            next_scroll_link = scrolling_list_page.wait_next[:href]

            expect(next_scroll_link).to(match(/\/page\/#{page_loop}\?/))
            visit_page(next_scroll_link, @user)
          end
        end while (next_scroll_link != nil)

        num_elements = model_class.count
        expect(num_elements / page_size + ((num_elements % page_size) > 0 ? 1 : 0)).to eq prev_page_loop
      end

      temp_model_class = described_class.name[0..-11].singularize.constantize
      (temp_model_class.reflect_on_all_associations(:has_many) +
          temp_model_class.reflect_on_all_associations(:has_and_belongs_to_many)).
          each do |has_many|
        relationship = has_many
        if (has_many.is_a?(ActiveRecord::Reflection::ThroughReflection))
          relationship = has_many.through_reflection
        end

        describe "paging #{has_many.plural_name}" do
          let(:parent_obj) { FactoryGirl.create(model_class.name.underscore.to_sym) }
          let(:not_parent_obj) { FactoryGirl.create(model_class.name.underscore.to_sym) }
          let(:child_scrolling_list_page) { RecipeRspecApp.child_scrolling_list_page(test_user,
                                                                                     model_class,
                                                                                     has_many.class_name.constantize,
                                                                                     has_many.plural_name) }
          let(:child_first_page) { parent_obj.send(has_many.plural_name).index_sort.page(1).to_a }
          let(:child_last_item) { parent_obj.send(has_many.plural_name).index_sort.last }
          let(:child_second_page) { parent_obj.send(has_many.plural_name).index_sort.page(2).to_a }

          before(:each) do
            has_many.class_name.constantize.paginates_per 2

            # ensure that there are enough child objects
            has_many_table_name = relationship.class_name.constantize.name
            foreign_key         = relationship.foreign_key.to_sym

            while parent_obj.send(has_many.plural_name).count < 10 do
              if has_many.macro == :has_and_belongs_to_many
                relation_name = has_many.plural_name

                if (has_many.options[:join_table])
                  has_many_table_name = has_many.options[:join_table].to_s.classify.constantize.name
                  fk_field            = has_many.options[:foreign_key]

                  child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym, fk_field => parent_obj.id)
                  child_object.save

                  child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym, fk_field => not_parent_obj.id)
                  child_object.save
                else
                  child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym)
                  child_object.save
                  parent_obj.send(relation_name) << child_object

                  child_object = FactoryGirl.build(has_many_table_name.underscore.to_sym)
                  child_object.save
                  not_parent_obj.send(relation_name) << child_object
                end
              else
                FactoryGirl.build(has_many_table_name.underscore.to_sym, foreign_key => parent_obj.id).save
                FactoryGirl.build(has_many_table_name.underscore.to_sym, foreign_key => not_parent_obj.id).save
              end
            end
          end

          it "should do something if it gets confused" do
            child_scrolling_list_page.load page_number: 1, parent_id: parent_obj.id,
                                           query:       { search_alias_id:                    1,
                                                          measuring_unit_id:                  1,
                                                          "#{model_class.name.underscore}_id" => 2 }

            expect(child_scrolling_list_page).to_not have_wait_previous
            expect(child_scrolling_list_page).to have_wait_next
            expect(child_scrolling_list_page.items.count).to eq 2
            expect(child_scrolling_list_page.items[0]).to have_content(test_scroll_list_name(child_first_page[0]))
            expect(child_scrolling_list_page.items[1]).to have_content(test_scroll_list_name(child_first_page[1]))
            expect(child_scrolling_list_page).to have_selected_item

            expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 2}/)
          end

          it "should return a partial page of data" do
            child_scrolling_list_page.load page_number: 1, parent_id: parent_obj.id

            expect(child_scrolling_list_page).to_not have_wait_previous
            expect(child_scrolling_list_page).to have_wait_next
            expect(child_scrolling_list_page.items.count).to eq 2
            expect(child_scrolling_list_page.items[0]).to have_content(test_scroll_list_name(child_first_page[0]))
            expect(child_scrolling_list_page.items[1]).to have_content(test_scroll_list_name(child_first_page[1]))
            expect(child_scrolling_list_page).to have_selected_item

            expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 2}/)
          end

          it "should return a middle page" do
            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: 2

            expect(child_scrolling_list_page).to have_wait_previous
            expect(child_scrolling_list_page).to have_wait_next
            expect(child_scrolling_list_page.items.count).to eq 2
            expect(child_scrolling_list_page.items[0]).to have_content(test_scroll_list_name(child_second_page[0]))
            expect(child_scrolling_list_page.items[1]).to have_content(test_scroll_list_name(child_second_page[1]))
            expect(child_scrolling_list_page).to_not have_selected_item

            expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 3}/)
            expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 1}/)
          end

          it "should return the last page" do
            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: ((parent_obj.send(has_many.plural_name).count / 2) + (parent_obj.send(has_many.plural_name).count % 2))

            expect(child_scrolling_list_page).to have_wait_previous
            expect(child_scrolling_list_page).to_not have_wait_next
            expect(child_scrolling_list_page.items.count).to be >= 1
            expect(child_scrolling_list_page.items[child_scrolling_list_page.items.count - 1]).
                to have_content(test_scroll_list_name(child_last_item))
            expect(child_scrolling_list_page).to_not have_selected_item

            expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: (parent_obj.send(has_many.plural_name).count / 2) + (parent_obj.send(has_many.plural_name).count % 2) - 1}/)
          end

          it "should accept a custom page_size" do
            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: 2, query: { per_page: 4 }

            expect(child_scrolling_list_page).to have_wait_previous
            expect(child_scrolling_list_page).to have_wait_next
            expect(child_scrolling_list_page.items.count).to eq 4
            expect(child_scrolling_list_page).to_not have_selected_item

            expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 3}/)
            expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 1}/)
          end

          it "should handle a page greater than the last page" do
            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: parent_obj.send(has_many.plural_name).count

            expect(child_scrolling_list_page).to have_wait_previous
            expect(child_scrolling_list_page).to_not have_wait_next
            expect(child_scrolling_list_page.items.count).to be 0
            expect(child_scrolling_list_page).to_not have_selected_item

            expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: parent_obj.send(has_many.plural_name).count - 1}/)
          end

          it "should highlight the selected item" do
            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: 2, query: { id: child_second_page[0].id }

            expect(child_scrolling_list_page).to have_wait_previous
            expect(child_scrolling_list_page).to have_wait_next
            expect(child_scrolling_list_page.items.count).to eq 2
            expect(child_scrolling_list_page.items[0]).to have_content(test_scroll_list_name(child_second_page[0]))
            expect(child_scrolling_list_page.items[1]).to have_content(test_scroll_list_name(child_second_page[1]))
            expect(child_scrolling_list_page.selected_item).to have_content(test_scroll_list_name(child_second_page[0]))
            expect(child_scrolling_list_page).to have_selected_item

            expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 3}/)
            expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 1}/)
          end

          it "should page search results" do
            # TODO: remove this if and unless eventually [has_many.class_name, has_many.options]
            if (has_many.class_name.constantize.respond_to?(:aliased?) && has_many.class_name.constantize.aliased) ||
                has_many.class_name.constantize == SearchAlias
              unless has_many.is_a?(ActiveRecord::Reflection::ThroughReflection)
                # TODO:  Is this reliable enough?  Can we/Should we make this better?
                child_scrolling_list_page.load parent_id: parent_obj.id, page_number: 2, query: { search: "e" }

                expect(child_scrolling_list_page).to have_wait_previous
                expect(child_scrolling_list_page).to have_wait_next
                expect(child_scrolling_list_page.items.count).to eq 2
                expect(child_scrolling_list_page).to_not have_selected_item

                expect(child_scrolling_list_page.wait_next[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 3}/)
                expect(child_scrolling_list_page.wait_previous[:href]).to match(/#{child_scrolling_list_page.url parent_id: parent_obj.id, page_number: 1}/)
              end
            end
          end

          it "should self-paginate" do
            prev_scroll_link = nil
            page_loop        = 1
            prev_page_loop   = 0
            next_scroll_link = nil
            page_size        = rand(2..4)

            child_scrolling_list_page.load parent_id: parent_obj.id, page_number: 1, query: { per_page: page_size }

            expect(child_scrolling_list_page).to have_no_wait_previous
            expect(child_scrolling_list_page.wait_next).to be

            begin
              prev_scroll_link = child_scrolling_list_page.wait_previous[:href] unless child_scrolling_list_page.has_no_wait_previous?
              if (prev_scroll_link)
                expect(child_scrolling_list_page.displayed?).to be_truthy
                expect(prev_scroll_link).to(match(/\/page\/#{prev_page_loop}\?/))
              end

              prev_page_loop += 1
              page_loop      += 1

              if child_scrolling_list_page.has_no_wait_next?
                next_scroll_link = nil
              else
                next_scroll_link = child_scrolling_list_page.wait_next[:href]

                expect(next_scroll_link).to(match(/\/page\/#{page_loop}\?/))
                visit_page(next_scroll_link, @user)
              end
            end while (next_scroll_link != nil)

            num_elements = parent_obj.send(has_many.plural_name).count
            expect(num_elements / page_size + ((num_elements % page_size) > 0 ? 1 : 0)).to eq prev_page_loop
          end
        end
      end
    end

    it "should handle an invalid id properly" do
      page_object.load item_id: model_class.maximum(:id) + 1
      expect(page_object.index_list).to be
    end

    #  describe "#index, #new, #show" do
    #    # page, per_page, search
    #    #page_object.load item_id: "new" # new
    #    #page_object.load item_id: first_page[0].id # show
    #    #page_object.load item_id: nil # index
    #  end
  end
end

RSpec.shared_examples "a searchable scrollable list controller" do
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
  let(:test_user) { FactoryGirl.create(:user) }
  let(:scrolling_list_page) { RecipeRspecApp.scrolling_list_page(test_user, model_class) }
  let(:action) { [:index, :page].sample }
  let(:item_action) { [:item, :edit, :show, :new_item, :new].sample }

  before(:each) do
    model_class.paginates_per 2
    while model_class.count < 20 do
      FactoryGirl.create(model_class.name.underscore.to_sym)
    end
  end

  describe "ScrollableListController", type: :controller do
    before(:each) do
      sign_in test_user
    end

    describe "json responses" do
      describe "#page or #index" do
        it "should show search results" do
          options        = { per_page: 2, format: "json", search: last_item[model_class.initialize_field] }
          options[:page] = 1 if action == :page

          get action, options

          expect(response).to be_success

          expect(assigns(described_class.controller_name).respond_to?(:current_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:first_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:last_page?)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:next_page)).to be_truthy
          expect(assigns(described_class.controller_name).respond_to?(:prev_page)).to be_truthy

          expect(assigns(described_class.controller_name.singularize)).to eq(last_item)
          expect(assigns(described_class.controller_name).count).to be >= 1
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(described_class.controller_name).first)
          expect(assigns(described_class.controller_name)).to eq(assigns(:current_page))
          expect(assigns(described_class.controller_name.singularize)).to eq(assigns(:selected_item))
          expect(assigns(:parent_obj)).to_not be
          expect(assigns(:parent_relationship)).to_not be
          expect(assigns(:parent_ref_field)).to_not be

          expect(response.content_type).to eq("application/json")
          json_body = JSON.parse(response.body)
          expect(json_body.length).to be >= 1
          expect(json_body[0].with_indifferent_access[:id]).to eq(last_item.id)
        end
      end
    end
  end
end