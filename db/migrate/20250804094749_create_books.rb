class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.text :description
      t.integer :publication_year
      t.integer :total_quantity, null: false, default: 0
      t.integer :available_quantity, null: false, default: 0
      t.integer :borrow_count, null: false, default: 0
      t.references :author, null: false, foreign_key: true
      t.references :publisher, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :books, :title
  end
end
