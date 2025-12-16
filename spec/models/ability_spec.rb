# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  subject(:ability) { described_class.new(user) }

  let(:book) { create(:book) }
  let(:author) { create(:author) }
  let(:other_user) { create(:user) }
  let(:borrow_request) { create(:borrow_request, user: user) }

  context "when user is an admin" do
    let(:user) { create(:user, :admin) }

    it "can manage all" do
      expect(ability).to be_able_to(:manage, Book.new)
      expect(ability).to be_able_to(:manage, Author.new)
      expect(ability).to be_able_to(:manage, User.new)
    end
  end

  context "when user is a logged-in normal user" do
    let(:user) { create(:user) }

    it "can read books, authors, favorites, follows" do
      expect(ability).to be_able_to(:read, book)
      expect(ability).to be_able_to(:read, author)
      expect(ability).to be_able_to(:read, :favorites)
      expect(ability).to be_able_to(:read, :follows)
    end

    it "can read own BorrowRequest and own User profile" do
      expect(ability).to be_able_to(:read, borrow_request)
      expect(ability).to be_able_to(:read, user)
    end

    it "cannot read others' BorrowRequest or User" do
      other_borrow_request = create(:borrow_request, user: other_user)
      expect(ability).not_to be_able_to(:read, other_borrow_request)
      expect(ability).not_to be_able_to(:read, other_user)
    end

    it "can update own profile" do
      expect(ability).to be_able_to(:update, user)
      expect(ability).not_to be_able_to(:update, other_user)
    end

    it "can cancel, edit_request, update_request for own BorrowRequest" do
      expect(ability).to be_able_to(:cancel, borrow_request)
      expect(ability).to be_able_to(:edit_request, borrow_request)
      expect(ability).to be_able_to(:update_request, borrow_request)
    end

    it "cannot manipulate others' BorrowRequest" do
      other_borrow_request = create(:borrow_request, user: other_user)
      expect(ability).not_to be_able_to(:cancel, other_borrow_request)
      expect(ability).not_to be_able_to(:edit_request, other_borrow_request)
      expect(ability).not_to be_able_to(:update_request, other_borrow_request)
    end

    it "can borrow books and manage favorites & reviews" do
      expect(ability).to be_able_to(:borrow, book)
      expect(ability).to be_able_to(:add_to_favorite, book)
      expect(ability).to be_able_to(:remove_from_favorite, book)
      expect(ability).to be_able_to(:write_a_review, book)
      expect(ability).to be_able_to(:destroy_review, book)
      expect(ability).to be_able_to(:add_to_favorite, author)
      expect(ability).to be_able_to(:remove_from_favorite, author)
    end
  end

  context "when user is a guest" do
    let(:user) { nil }

    it "can read books, authors, home, about, search" do
      expect(ability).to be_able_to(:read, book)
      expect(ability).to be_able_to(:read, author)
      expect(ability).to be_able_to(:read, :home)
      expect(ability).to be_able_to(:read, :about)
      expect(ability).to be_able_to(:read, :search)
    end

    it "cannot borrow, favorite, update, or manage other resources" do
      expect(ability).not_to be_able_to(:borrow, book)
      expect(ability).not_to be_able_to(:update, User.new)
      expect(ability).not_to be_able_to(:add_to_favorite, author)
      expect(ability).not_to be_able_to(:write_a_review, book)
    end
  end
end
