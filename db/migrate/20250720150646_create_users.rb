class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.integer :gender, null: false
      t.date :date_of_birth, null: false
      t.integer :status, null: false, default: 0
      t.string :phone_number, limit: 20
      t.string :address
      t.string :activation_token
      t.datetime :activated_at

      t.timestamps null: false
    end
  end
end
