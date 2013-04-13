require "spec_helper"

describe MeasuringUnitsController do
  before(:each) do
    @test_user = FactoryGirl.create(:user)
    sign_in @test_user
  end

  describe "create" do
    it "should set the has abbreviation" do
      @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit)
      @test_measuring_unit[:has_abbreviation] = false

      post :create, measuring_unit: @test_measuring_unit

      response.should be_redirect
      response.should redirect_to(measuring_unit_path(assigns(:measuring_unit).id))
    end
  end

  describe "update" do
    it "should set the has abbreviation" do
      @update_measuring_unit                  = FactoryGirl.create(:measuring_unit, abbreviation: Faker::Name.name)
      @test_measuring_unit                    = FactoryGirl.attributes_for(:measuring_unit)
      @test_measuring_unit[:has_abbreviation] = false

      post :update, id: @update_measuring_unit.id, measuring_unit: @test_measuring_unit

      response.should be_success
      #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))
    end
  end

  describe "scrolling list" do
    before(:each) do
      @paged_test_page     = 2
      @paged_test_per_page = 2
      @paged_test_item     = MeasuringUnit.all[(@paged_test_page - 1) * @paged_test_per_page]
    end

    it "should list items" do
      get :index, per_page: @paged_test_per_page

      response.should be_success

      assigns(:measuring_units).count.should eq(@paged_test_per_page)
      assigns(:measuring_unit).should eq(assigns(:measuring_units).first)
      assigns(:measuring_units).should eq(assigns(:current_page))
      assigns(:measuring_unit).should eq(assigns(:selected_item))
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
      it "should not be able to delete seed units" do
        do_not_delete = MeasuringUnit.find_or_initialize("cup")

        delete :destroy, id: do_not_delete.id, page: @paged_test_page, per_page: @paged_test_per_page

        response.should be_success
        flash[:error].should eq(I18n.t("scrolling_list_controller.delete.failure", resource_name: "Measuring unit"))
        assigns(:selected_item).should eq(do_not_delete)
      end

      it "should delete non seed units" do
        delete_unit = FactoryGirl.create(:measuring_unit)

        delete :destroy, id: delete_unit.id, page: @paged_test_page, per_page: @paged_test_per_page

        response.should be_success
        assigns(:selected_item).should eq(MeasuringUnit.first)
        find_unit = MeasuringUnit.where(id: delete_unit.id).first
        find_unit.should be_blank
      end

      it "should not be able to delete fake units" do
        delete :destroy, id: -1, page: @paged_test_page, per_page: @paged_test_per_page

        response.should be_success
        flash[:error].should eq(I18n.t("scrolling_list_controller.delete.failure", resource_name: "Measuring unit"))
        assigns(:selected_item).id.should be_blank
      end
    end

    describe "posting data" do
      before(:each) do
        @new_values                    = FactoryGirl.attributes_for(:measuring_unit)
        @new_values[:has_abbreviation] = !@new_values[:abbreviation].blank?
      end

      describe "create" do
        it "should create units" do
          post :create, page: @paged_test_page, per_page: @paged_test_per_page, measuring_unit: @new_values

          response.should be_redirect
          response.should redirect_to(measuring_unit_path assigns(:selected_item))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).name.should eq(@new_values[:name])
          assigns(:selected_item).can_delete.should eq(true)
        end

        it "should not create invalid units" do
          @new_values[:name]             = ""
          @new_values[:abbreviation]     = Faker::Lorem.sentence
          @new_values[:has_abbreviation] = true

          post :create, page: @paged_test_page, per_page: @paged_test_per_page, measuring_unit: @new_values

          response.should be_success
          flash[:error].should_not be_blank
          assigns(:selected_item).abbreviation.should eq(@new_values[:abbreviation])
        end
      end

      describe "update" do
        before(:each) do
          @new_item = FactoryGirl.create(:measuring_unit)
        end

        it "should update units" do
          post :update, id: @new_item.id + 99999, page: @paged_test_page, per_page: @paged_test_per_page, measuring_unit: @new_values

          response.should be_success
          #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).name.should eq(@new_values[:name])
          assigns(:selected_item).can_delete.should eq(true)
        end

        it "should update units" do
          post :update, id: @new_item.id, page: @paged_test_page, per_page: @paged_test_per_page, measuring_unit: @new_values

          response.should be_success
          #flash[:notice].should eq(I18n.t("scrolling_list_controller.update.success", resource_name: "Measuring unit"))

          assigns(:selected_item).id.should_not be_blank
          assigns(:selected_item).name.should eq(@new_values[:name])
          assigns(:selected_item).can_delete.should eq(true)
        end

        it "should not update invalid units" do
          @new_values[:name]             = ""
          @new_values[:abbreviation]     = Faker::Lorem.sentence
          @new_values[:has_abbreviation] = true

          post :update, id: @new_item.id, page: @paged_test_page, per_page: @paged_test_per_page, measuring_unit: @new_values

          response.should be_success
          flash[:error].should_not be_blank
          assigns(:selected_item).abbreviation.should eq(@new_values[:abbreviation])

          load_unit = MeasuringUnit.find(@new_item.id)
          load_unit.should eq(@new_item)
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