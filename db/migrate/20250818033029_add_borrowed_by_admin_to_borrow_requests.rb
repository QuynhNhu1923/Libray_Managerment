class AddBorrowedByAdminToBorrowRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :borrow_requests, :borrowed_by_admin_id, :bigint
  end
end
