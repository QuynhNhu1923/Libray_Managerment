class CreateBorrowRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :borrow_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :request_date, null: false
      t.integer :status, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.date :actual_return_date
      t.text :admin_note
      t.bigint :approved_by_admin_id

      t.timestamps null: false
    end

    add_index :borrow_requests, :status
    add_index :borrow_requests, :approved_by_admin_id
    add_foreign_key :borrow_requests, :users, column: :approved_by_admin_id
  end
end
