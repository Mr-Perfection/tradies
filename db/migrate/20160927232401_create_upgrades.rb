class CreateUpgrades < ActiveRecord::Migration[5.0]
  def change
    create_table :upgrades do |t|
      t.string :name
      t.float :price
      t.string :wepay_access_token
      t.integer :wepay_account_id

      t.timestamps
    end
  end
end
