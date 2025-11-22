class BorrowRequest < ApplicationRecord
  OVERDUE = "end_date < ? AND status = ?".freeze

  belongs_to :user
  belongs_to :approved_by_admin, class_name: User.name, optional: true
  has_many :borrow_request_items, dependent: :destroy
  has_many :books, through: :borrow_request_items
end
