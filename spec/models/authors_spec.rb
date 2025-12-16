# spec/models/author_spec.rb
require 'rails_helper'

RSpec.describe Author, type: :model do
  describe "associations" do
    it { should have_many(:books).dependent(:restrict_with_error) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_one_attached(:image) }
  end

  describe "validations" do
    subject { build(:author) } # giả sử bạn đã có factory

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(Author::MAX_NAME_LENGTH) }
    it { should validate_length_of(:bio).is_at_most(Author::MAX_BIO_LENGTH) }
    it { should validate_length_of(:nationality).is_at_most(Author::MAX_NATIONALITY_LENGTH) }

    describe "birth_date validation" do
      it "is valid if birth_date is in the past" do
        author = build(:author, birth_date: 1.year.ago)
        expect(author).to be_valid
      end

      it "is invalid if birth_date is in the future" do
        author = build(:author, birth_date: 1.day.from_now)
        expect(author).not_to be_valid
        expect(author.errors[:birth_date]).to include("must be less than #{Date.current}")
      end
    end

    describe "death_date validation" do
      it "is valid if death_date is after birth_date and not in the future" do
        author = build(:author, birth_date: 50.years.ago, death_date: 1.year.ago)
        expect(author).to be_valid
      end

      it "is invalid if death_date is before birth_date" do
        author = build(:author, birth_date: 50.years.ago, death_date: 60.years.ago)
        expect(author).not_to be_valid
      end

      it "is invalid if death_date is in the future" do
        author = build(:author, birth_date: 50.years.ago, death_date: 1.day.from_now)
        expect(author).not_to be_valid
      end
    end
  end

  describe "scopes" do
    before do
      @alive_author = create(:author, death_date: nil)
      @deceased_author = create(:author, death_date: 1.year.ago)
    end

    it ".alive returns authors with no death_date" do
      expect(Author.alive).to include(@alive_author)
      expect(Author.alive).not_to include(@deceased_author)
    end

    it ".deceased returns authors with death_date present" do
      expect(Author.deceased).to include(@deceased_author)
      expect(Author.deceased).not_to include(@alive_author)
    end

    it ".recent returns authors in descending order of created_at" do
      recent_author = create(:author)
      expect(Author.recent.first).to eq(recent_author)
    end
  end

  describe ".ransackable_attributes" do
    it "returns only name" do
      expect(Author.ransackable_attributes).to eq(["name"])
    end
  end
end
