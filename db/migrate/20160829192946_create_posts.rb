class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string     :subject
      t.string     :street_address
      t.string     :city
      t.string     :state
      t.string     :zip
      t.float      :price
      t.text       :content
      t.references :user, foreign_key: true
      t.timestamps
    end
    add_column :posts, :interested, :boolean, default: false
    add_column :posts, :sold, :boolean, default: false
    add_column :posts, :sold_user_id, :integer
    add_index :posts, [:user_id, :created_at]
  end
end
