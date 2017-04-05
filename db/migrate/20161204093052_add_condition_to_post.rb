class AddConditionToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :condition, :string
  end
end
