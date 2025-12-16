class CreatePublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :publishers do |t|
      t.string :name, null: false
      t.string :address
      t.string :phone_number, limit: 20
      t.string :email
      t.string :website

      t.timestamps null: false
    end

    add_index :publishers, :name, unique: true
  end
end
