class CreateInterestedUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :interested_users do |t|
      t.integer :interested_users_list_id
      t.integer :user_id

      t.timestamps
    end
    add_index :interested_users, :interested_users_list_id
    add_index :interested_users, :user_id
    add_index :interested_users, [:interested_users_list_id, :user_id], unique: true
  end
end
