class BorrowRequestItem < ApplicationRecord
  belongs_to :borrow_request
  belongs_to :book
end
