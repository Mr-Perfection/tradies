class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.timestamps
    end

    add_column :users, :wepay_access_token, :string
	  add_column :users, :wepay_account_id, :integer
	  add_column :users, :description, :text
  end
end
