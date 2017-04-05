class AddEmailAddressToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :email_address, :string
  end
end
