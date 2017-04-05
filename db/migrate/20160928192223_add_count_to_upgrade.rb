class AddCountToUpgrade < ActiveRecord::Migration[5.0]
  def change
    add_column :upgrades, :count, :integer, limit: 8, default: 0
  end
end
