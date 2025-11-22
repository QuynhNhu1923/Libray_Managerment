class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.text :bio
      t.date :birth_date
      t.date :death_date
      t.string :nationality, limit: 100

      t.timestamps null: false
    end
  end
end
