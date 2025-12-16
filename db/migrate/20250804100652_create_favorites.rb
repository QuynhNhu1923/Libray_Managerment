class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :favorable, null: false, polymorphic: true

      t.timestamps null: false
    end

    add_index :favorites, [:favorable_id, :favorable_type]
    add_index :favorites, [:user_id, :favorable_id, :favorable_type], unique: true, name: 'index_favorites_on_user_and_favorable'
  end
end
