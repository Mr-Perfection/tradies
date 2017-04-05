class AddPhoneNumberToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :phone_number, :string
  end
end
