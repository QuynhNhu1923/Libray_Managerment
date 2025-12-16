# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) } # dùng factory bot

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(User::NAME_MAX_LENGTH) }

    it { should validate_presence_of(:email) }
    it { should validate_length_of(:email).is_at_most(User::EMAIL_MAX_LENGTH) }
    it { should allow_value("test@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }

    it { should validate_presence_of(:gender) }

    it "validates length of password if password_required?" do
        user.password = "123"
        if user.send(:password_required?)
            expect(user).to be_invalid
            expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
        end
        end


    it do
      should allow_value("+84912345678").for(:phone_number)
      should_not allow_value("12345").for(:phone_number)
    end

    it do
      should validate_length_of(:address)
        .is_at_most(500)
        .allow_blank
    end
  end

  describe "enums" do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1, super_admin: 2) }
    it { should define_enum_for(:gender).with_values(male: 0, female: 1, other: 2) }
    it { should define_enum_for(:status).with_values(inactive: 0, active: 1) }
  end

  describe "associations" do
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:favorite_books).through(:favorites).source(:favorable) }
    it { should have_many(:favorite_authors).dependent(:destroy) }
    it { should have_many(:followed_authors).through(:favorite_authors).source(:favorable) }
    it { should have_many(:borrow_requests).dependent(:destroy) }
    it { should have_one_attached(:avatar) }
    it { should have_one_attached(:image) }
  end

  describe "#favorited?" do
    let(:book) { create(:book) }
    it "returns true if user has favorited the item" do
      user.save
      user.favorites.create!(favorable: book)
      expect(user.favorited?(book)).to be_truthy
    end

    it "returns false if user has not favorited the item" do
      expect(user.favorited?(book)).to be_falsey
    end
  end

  describe "#date_of_birth_must_be_within_last_100_years" do
    it "is valid if date_of_birth within last 100 years" do
      user.date_of_birth = 20.years.ago.to_date
      expect(user).to be_valid
    end

    it "adds error if date_of_birth more than 100 years ago" do
      user.date_of_birth = 101.years.ago.to_date
      expect(user).to be_invalid
    end

    it "adds error if date_of_birth in the future" do
      user.date_of_birth = 1.day.from_now.to_date
      expect(user).to be_invalid
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456",
        info: { name: "Test User", email: "test@example.com" }
      )
    end

    context "when user exists with provider and uid" do
      let!(:existing_user) { create(:user, provider: "google_oauth2", uid: "123456") }

      it "returns the existing user" do
        expect(User.from_omniauth(auth)).to eq(existing_user)
      end
    end

    context "when user exists by email but no provider/uid" do
      let!(:existing_user) { create(:user, email: "test@example.com", provider: nil, uid: nil) }

      it "updates provider and uid and returns user" do
        user = User.from_omniauth(auth)
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456")
      end
    end

    context "when user does not exist" do
      it "creates a new user with omniauth info" do
        user = User.from_omniauth(auth)
        expect(user).to be_persisted
        expect(user.email).to eq("test@example.com")
        expect(user.provider).to eq("google_oauth2")
        expect(user.uid).to eq("123456")
      end
    end
  end
end
