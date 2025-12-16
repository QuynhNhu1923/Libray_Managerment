# spec/models/category_spec.rb
require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { build(:category) }

  describe "associations" do
    it { should have_many(:book_categories).dependent(:restrict_with_error) }
    it { should have_many(:books).through(:book_categories) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(Category::MAX_NAME_LENGTH) }
    it { should validate_uniqueness_of(:name).case_insensitive }

    it { should validate_length_of(:description).is_at_most(Category::MAX_DESCRIPTION_LENGTH) }
  end

  describe "delegate methods" do
    it "delegates books_count to books.count" do
      category = create(:category)
      book1 = create(:book)
      book2 = create(:book)
      create(:book_category, category: category, book: book1)
      create(:book_category, category: category, book: book2)

      expect(category.books_count).to eq(2)
    end
  end

  describe "scopes" do
    describe ".recent" do
      it "orders categories by created_at descending" do
        old_category = create(:category, created_at: 2.days.ago)
        new_category = create(:category, created_at: 1.day.ago)

        expect(Category.recent).to eq([new_category, old_category])
      end
    end

    describe ".with_books" do
      it "returns only categories that have books" do
        category_with_books = create(:category)
        category_without_books = create(:category)
        book = create(:book)
        create(:book_category, category: category_with_books, book: book)

        expect(Category.with_books).to include(category_with_books)
        expect(Category.with_books).not_to include(category_without_books)
      end
    end

    describe ".without_books" do
      it "returns only categories that have no books" do
        category_with_books = create(:category)
        category_without_books = create(:category)
        book = create(:book)
        create(:book_category, category: category_with_books, book: book)

        expect(Category.without_books).to include(category_without_books)
        expect(Category.without_books).not_to include(category_with_books)
      end
    end
  end
end
