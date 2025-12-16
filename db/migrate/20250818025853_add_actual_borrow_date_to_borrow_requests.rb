class AddActualBorrowDateToBorrowRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :borrow_requests, :actual_borrow_date, :date
  end
end
