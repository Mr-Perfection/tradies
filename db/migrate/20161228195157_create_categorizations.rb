class CreateCategorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :categorizations do |t|
      t.integer :post_id
      t.integer :category_id

      t.timestamps
    end
    add_index :categorizations, :post_id
    add_index :categorizations, :category_id
    add_index :categorizations, [:post_id, :category_id], unique: true
  end
end
