class CreateBorrowRequestItems < ActiveRecord::Migration[7.0]
  def change
    create_table :borrow_request_items do |t|
      t.references :borrow_request, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
    end

    add_index :borrow_request_items, [:borrow_request_id, :book_id], unique: true
  end
end
