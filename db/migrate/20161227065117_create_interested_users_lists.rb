class CreateInterestedUsersLists < ActiveRecord::Migration[5.0]
  def change
    create_table :interested_users_lists do |t|
      t.belongs_to :post, index: true
      t.timestamps
    end
  end
end
