class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.integer :score, null: false
      t.text :comment

      t.timestamps null: false
    end

    add_index :reviews, [:user_id, :book_id], unique: true
  end
end
