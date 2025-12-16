class AddApprovedDateToBorrowRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :borrow_requests, :approved_date, :date
  end
end
