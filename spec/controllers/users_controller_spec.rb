require "rails_helper"

# The user pages are scaffolded, and I don't currently support users really, so these are just
# basic tests to establish coverage.

RSpec.describe UsersController, type: :controller do
  describe "an authenticated user" do
    before(:each) do
      @test_user = FactoryGirl.create(:user)
      sign_in @test_user
    end

    describe "index" do
      it "should list all users" do
        get :index
        expect(response).to be_success
        expect(assigns(:users)).to eq(User.all)
      end
    end

    describe "show" do
      it "should show the uer" do
        get :show, id: @test_user.id
        expect(response).to be_success
        expect(assigns(:user)).to eq(@test_user)
      end
    end

    describe "new" do
      it "should render a page" do
        get :new
        expect(response).to be_success
        expect(assigns(:user).id).to be_blank
      end
    end

    describe "edit" do
      it "should render a page" do
        get :edit, id: @test_user.id
        expect(response).to be_success
        expect(assigns(:user)).to eq(@test_user)
      end
    end

    describe "create" do
      before(:each) do
        @new_user_information = FactoryGirl.attributes_for(:user)
      end

      it "should create a new user" do
        post :create, user: @new_user_information

        expect(response).to be_redirect
        expect(response).to redirect_to(user_path(assigns(:user).id))
        expect(flash[:notice]).to eq(I18n.t("user.create.success"))

        new_user = User.find(assigns(:user).id)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            expect(new_user.send(key)).to eq(value)
          end
        end
      end

      it "should not save if there is an error" do
        @new_user_information[:name] = ""

        post :create, user: @new_user_information

        expect(response).to be_success

        new_user = assigns(:user)
        expect(new_user.id).to be_blank
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            expect(new_user.send(key)).to eq(value)
          end
        end
      end
    end

    describe "update" do
      before(:each) do
        @new_user_information = FactoryGirl.attributes_for(:user)
      end

      it "should render a page" do
        patch :update, id: @test_user.id, user: @new_user_information

        expect(response).to be_redirect
        expect(response).to redirect_to(user_path(assigns(:user).id))
        expect(flash[:notice]).to eq(I18n.t("user.update.success"))

        loaded_user = User.find(@test_user.id)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            expect(loaded_user.send(key)).to eq(value)
          end
        end
      end

      it "should not update the user if update is invalid" do
        @new_user_information[:name] = ""
        original_name                = @test_user.name

        patch :update, id: @test_user.id, user: @new_user_information

        expect(response).to be_success

        new_user = User.find(@test_user.id)
        expect(new_user.name).to eq(original_name)
        @new_user_information.each do |key, value|
          unless (key == :password || key == :password_confirmation)
            expect(new_user.send(key)).not_to eq(value)
          end
        end
      end
    end

    describe "delete" do
      it "should delete another user" do
        new_user = FactoryGirl.create(:user)

        delete :destroy, id: new_user.id

        expect(response).to be_redirect
        expect(response).to redirect_to(users_path)

        find_user = User.where(id: new_user.id).first
        expect(find_user).to be_blank
      end

      it "should not delete self" do
        delete :destroy, id: @test_user.id

        expect(response).to be_redirect
        expect(response).to redirect_to(users_path)
        expect(flash[:notice]).to eq(I18n.t("user.delete.self"))

        find_user = User.where(id: @test_user.id).first
        expect(find_user).to eq(@test_user)
      end
    end
  end

  describe "an unauthenticated user" do
    before(:each) do
      @test_user = FactoryGirl.create(:user)
    end

    it "should require a user for index" do
      get :index
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for show"do
      get :show, id: @test_user.id
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for new" do
      get :new
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for edit" do
      get :edit, id: @test_user.id
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for create" do
      post :create
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for update" do
      patch :update, id: @test_user.id
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end

    it "should require a user for delete" do
      delete :destroy, id: @test_user.id
      expect(response).to be_redirect
      expect(response).to redirect_to("/users/sign_in")
      expect(flash[:alert]).to eq(I18n.t("devise.failure.unauthenticated"))
    end
  end
end