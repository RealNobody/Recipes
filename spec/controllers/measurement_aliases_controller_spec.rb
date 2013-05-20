require "spec_helper"
require "faker"

describe MeasurementAliasesController do
  before(:each) do
    @test_user = FactoryGirl.create(:user)
    sign_in @test_user
  end

  describe "create" do
    it "should set the has abbreviation" do
      @test_measurement_alias = { alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id }

      post :create, measurement_alias: @test_measurement_alias

      response.should be_redirect
      response.should redirect_to(measurement_alias_path(assigns(:measurement_alias).id))
    end
  end

  describe "update" do
    it "should set an alias" do
      @update_measurement_alias = MeasurementAlias.create(alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id)
      @test_measurement_alias   = { alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id }

      post :update, id: @update_measurement_alias.id, measurement_alias: @test_measurement_alias

      response.should be_success
    end
  end

  describe "scrolling list" do
    before(:each) do
      @paged_test_page     = 2
      @paged_test_per_page = 2
      @paged_test_item     = MeasurementAlias.index_sort.all[(@paged_test_page - 1) * @paged_test_per_page]
    end

    it "should list items" do
      get :index, per_page: @paged_test_per_page

      response.should be_success

      assigns(:measurement_aliases).count.should eq(@paged_test_per_page)
      assigns(:measurement_alias).should eq(assigns(:measurement_aliases).index_sort.first)
      assigns(:measurement_aliases).should eq(assigns(:current_page))
      assigns(:measurement_alias).should eq(assigns(:selected_item))
    end

    it "should list items" do
      get :index, per_page: @paged_test_per_page

      response.should be_success

      assigns(:measurement_aliases).count.should eq(@paged_test_per_page)
      assigns(:measurement_alias).should eq(assigns(:measurement_aliases).first)
      assigns(:measurement_aliases).should eq(assigns(:current_page))
      assigns(:measurement_alias).should eq(assigns(:selected_item))
    end

    it "should render a partial of page information" do
      get :page, page: @paged_test_page, per_page: @paged_test_per_page

      response.should be_success

      assigns(:current_page).first.should eq(@paged_test_item)
    end

    it "should be able to edit an item" do
      get :edit, id: @paged_test_item.id, page: @paged_test_page, per_page: @paged_test_per_page

      response.should be_success

      assigns(:selected_item).should eq(@paged_test_item)
      assigns(:current_page).first.should eq(@paged_test_item)
    end

    it "should be able to create item" do
      get :new, page: @paged_test_page, per_page: @paged_test_per_page

      response.should be_success

      assigns(:selected_item).id.should be_blank
      assigns(:current_page).first.should eq(@paged_test_item)
    end

    it "should be able to create item segment" do
      get :new_item, page: @paged_test_page, per_page: @paged_test_per_page

      response.should be_success

      assigns(:selected_item).id.should be_blank
      assigns(:current_page).first.should eq(@paged_test_item)
    end

    describe "Delete" do
      it "should delete aliases" do
        delete_alias = MeasurementAlias.create(alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id)

        delete :destroy, id: delete_alias.id, page: @paged_test_page, per_page: @paged_test_per_page

        response.should be_success
        assigns(:selected_item).should eq(MeasurementAlias.index_sort.first)
        find_alias = MeasurementAlias.where(id: delete_alias.id).first
        find_alias.should be_blank
      end

      it "should not be able to delete fake aliases" do
        delete :destroy, id: -1, page: @paged_test_page, per_page: @paged_test_per_page

        response.should be_success
        flash[:error].should eq(I18n.t("scrolling_list_controller.delete.failure", resource_name: "Measurement alias"))
        assigns(:selected_item).id.should be_blank
      end
    end

    describe "posting data" do
      before(:each) do
        @new_values = { alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id }
      end

      describe "create" do
        it "should create aliases" do
          post :create, page: @paged_test_page, per_page: @paged_test_per_page, measurement_alias: @new_values

          response.should be_redirect
          response.should redirect_to(measurement_alias_path assigns(:selected_item))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).alias.should eq(@new_values[:alias].downcase)
        end

        it "should not create invalid aliases" do
          @new_values[:alias] = ""

          post :create, page: @paged_test_page, per_page: @paged_test_per_page, measurement_alias: @new_values

          response.should be_success
          flash[:error].should_not be_blank
          assigns(:selected_item).alias.should eq(@new_values[:alias].downcase)
        end
      end

      describe "update" do
        before(:each) do
          @new_item = MeasurementAlias.create(alias: Faker::Lorem.sentence, measuring_unit_id: MeasuringUnit.first.id)
        end

        it "should update aliases" do
          post :update, id: @new_item.id + 99999, page: @paged_test_page, per_page: @paged_test_per_page, measurement_alias: @new_values

          response.should be_success
          #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).alias.should eq(@new_values[:alias].downcase)
        end

        it "should update aliases" do
          post :update, id: @new_item.id, page: @paged_test_page, per_page: @paged_test_per_page, measurement_alias: @new_values

          response.should be_success
          #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).alias.should eq(@new_values[:alias].downcase)
        end

        it "should not update invalid aliases" do
          @new_values[:alias] = ""

          post :update, id: @new_item.id, page: @paged_test_page, per_page: @paged_test_per_page, measurement_alias: @new_values

          response.should be_success
          flash[:error].should_not be_blank
          assigns(:selected_item).alias.should eq(@new_values[:alias].downcase)

          load_alias = MeasurementAlias.find(@new_item.id)
          load_alias.should eq(@new_item)
        end
      end
    end

    it "should get just the item page" do
      get :item, id: @paged_test_item.id, page: @paged_test_page, per_page: @paged_test_per_page

      response.should be_success
      assigns(:selected_item).should eq(@paged_test_item)
    end

    it "should show a new/blank form if the item cannot be found" do
      get :item, id: -1, page: @paged_test_page, per_page: @paged_test_per_page

      response.should_not be_success
      response.status.should eq(404)
      assigns(:selected_item).id.should be_blank
    end
  end
end