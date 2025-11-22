class Author < ApplicationRecord
  has_one_attached :image

  has_many :books, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
end
