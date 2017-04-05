class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.string :activation_digest
      t.boolean :activated
      t.boolean :satisfied
      t.integer :reviewee_id
      t.integer :reviewer_id
      t.integer :post_id
      t.text    :comment
      t.datetime :activated_at
      t.timestamps
    end
      add_index :reviews, :post_id
      add_index :reviews, :reviewee_id
      add_index :reviews, :reviewer_id
      add_index :reviews, [:post_id, :reviewee_id, :reviewer_id]
  end
end
