# spec/models/book_category_spec.rb
require "rails_helper"

RSpec.describe BookCategory, type: :model do
  describe "associations" do
    it { should belong_to(:book) }
    it { should belong_to(:category) }
  end

  describe "validations" do
    it "is valid with valid book and category" do
      book_category = FactoryBot.build(:book_category)
      expect(book_category).to be_valid
    end

    it "is invalid without a book" do
      book_category = FactoryBot.build(:book_category, book: nil)
      expect(book_category).not_to be_valid
      expect(book_category.errors[:book]).to include("must exist")
    end

    it "is invalid without a category" do
      book_category = FactoryBot.build(:book_category, category: nil)
      expect(book_category).not_to be_valid
      expect(book_category.errors[:category]).to include("must exist")
    end
  end
end
