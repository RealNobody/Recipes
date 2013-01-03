require "spec_helper"

describe User do
  before do
    @user = User.new(name: "Test User",
                      email: "Test.User@sample.com",
                      password: "Password")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }

  it { should be_valid }

  describe "when name is missing" do
    before do
      @user.name = ""
    end
    it { should_not be_valid }
  end

  describe "when email is missing" do
    before do
      @user.email = ""
    end
    it { should_not be_valid }
  end

  describe "when password is missing" do
    before do
      @user.password = @user.password_confirmation = ""
    end

    it { should_not be_valid }
  end

  describe "when password is too short" do
    before do
      @user.password = @user.password_confirmation = "a"
    end

    it { should_not be_valid }
  end

  describe "when password is too long" do
    before do
      @user.password = @user.password_confirmation = "a" * 256
    end

    it { should_not be_valid }
  end

  describe "when email is already in use" do
    before do
      duplicate_user = @user.dup
      duplicate_user.name += " test"
      duplicate_user.save
    end

    it { should_not be_valid }
  end

  describe "when username is already in use" do
    before do
      duplicate_user = @user.dup
      duplicate_user.email += ".org"
      duplicate_user.save
    end

    it { should_not be_valid }
  end

  describe "when email case insensetive is already in use" do
    before do
      duplicate_user = @user.dup
      duplicate_user.name += " test"
      duplicate_user.email = duplicate_user.email.upcase
      duplicate_user.save
    end

    it { should_not be_valid }
  end

  describe "when username is already in use" do
    before do
      duplicate_user = @user.dup
      duplicate_user.name = duplicate_user.name.upcase
      duplicate_user.email += ".org"
      duplicate_user.save
    end

    it { should_not be_valid }
  end
end