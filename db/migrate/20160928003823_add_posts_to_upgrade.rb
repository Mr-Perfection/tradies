class AddPostsToUpgrade < ActiveRecord::Migration[5.0]
  def change
    add_column :upgrades, :posts, :integer
  end
end
