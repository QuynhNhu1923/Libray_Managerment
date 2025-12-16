class AddDigestFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :remember_digest, :string
    add_column :users, :reset_digest, :string

    add_index :users, :remember_digest
    add_index :users, :reset_digest
  end
end
