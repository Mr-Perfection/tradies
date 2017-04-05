class AddAttributesToPost < ActiveRecord::Migration[5.0]
  def change
  	add_column :posts, :tradies, :boolean, default: false
    add_column :posts, :is_firm, :boolean, default: true
  end
end
