require "spec_helper"

# The user pages are scaffolded, and I don't currently support users really, so these are just
# basic tests to establish coverage.

describe UsersController do
  describe "an authenticated user" do
    before(:each) do
      @test_user = FactoryGirl.create(:user)
      sign_in @test_user
    end

    describe "index" do
      it "should list all users" do
        get :index
        response.should be_success
        assigns(:users).should eq(User.all)
      end
    end

    describe "show" do
      it "should show the uer" do
        get :show, id: @test_user.id
        response.should be_success
        assigns(:user).should eq(@test_user)
      end
    end

    describe "new" do
      it "should render a page" do
        get :new
        response.should be_success
        assigns(:user).id.should be_blank
      end
    end

    describe "edit" do
      it "should render a page" do
        get :edit, id: @test_user.id
        response.should be_success
        assigns(:user).should eq(@test_user)
      end
    end

    describe "create" do
      before(:each) do
        @new_user_information = FactoryGirl.attributes_for(:user)
      end

      it "should create a new user" do
        post :create, user: @new_user_information

        response.should be_redirect
        response.should redirect_to(user_path(assigns(:user).id))
        flash[:notice].should eq(I18n.t("user.create.success"))

        new_user = User.find(assigns(:user).id)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            new_user.send(key).should eq(value)
          end
        end
      end

      it "should not save if there is an error" do
        @new_user_information[:name] = ""

        post :create, user: @new_user_information

        response.should be_success

        new_user = assigns(:user)
        new_user.id.should be_blank
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            new_user.send(key).should eq(value)
          end
        end
      end
    end

    describe "update" do
      before(:each) do
        @new_user_information = FactoryGirl.attributes_for(:user)
      end

      it "should render a page" do
        post :update, id: @test_user.id, user: @new_user_information

        response.should be_redirect
        response.should redirect_to(user_path(assigns(:user).id))
        flash[:notice].should eq(I18n.t("user.update.success"))

        loaded_user = User.find(@test_user.id)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            loaded_user.send(key).should eq(value)
          end
        end
      end

      it "should not update the user if update is invalid" do
        @new_user_information[:name] = ""
        original_name                = @test_user.name

        post :update, id: @test_user.id, user: @new_user_information

        response.should be_success

        new_user = User.find(@test_user.id)
        new_user.name.should eq(original_name)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            new_user.send(key).should_not eq(value)
          end
        end
      end
    end

    describe "delete" do
      it "should delete another user" do
        new_user = FactoryGirl.create(:user)

        delete :destroy, id: new_user.id

        response.should be_redirect
        response.should redirect_to(users_path)

        find_user = User.where(id: new_user.id).first
        find_user.should be_blank
      end

      it "should not delete self" do
        delete :destroy, id: @test_user.id

        response.should be_redirect
        response.should redirect_to(users_path)
        flash[:notice].should eq(I18n.t("user.delete.self"))

        find_user = User.where(id: @test_user.id).first
        find_user.should eq(@test_user)
      end
    end
  end

  describe "an unauthenticated user" do
    before(:each) do
      @test_user = FactoryGirl.create(:user)
    end

    it "should require a user for index" do
      get :index
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for show"do
      get :show, id: @test_user.id
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for new" do
      get :new
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for edit" do
      get :edit, id: @test_user.id
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for create" do
      post :create
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for update" do
      post :update, id: @test_user.id
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for delete" do
      delete :destroy, id: @test_user.id
      response.should be_redirect
      response.should redirect_to("/users/sign_in")
      flash[:alert].should eq(I18n.t("devise.failure.unauthenticated"))
    end
  end
end