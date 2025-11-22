class Book < ApplicationRecord
  has_one_attached :image

  belongs_to :author
  belongs_to :publisher
  has_many :book_categories, dependent: :destroy
  has_many :categories, through: :book_categories
  has_many :borrow_request_items, dependent: :destroy
  has_many :borrow_requests, through: :borrow_request_items
  has_many :reviews, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
end
