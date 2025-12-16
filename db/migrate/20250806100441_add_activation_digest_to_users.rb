class AddActivationDigestToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :activation_digest, :string
  end
end
