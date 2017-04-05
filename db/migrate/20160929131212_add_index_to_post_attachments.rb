class AddIndexToPostAttachments < ActiveRecord::Migration[5.0]
  def change
  	add_index :post_attachments, :post_id, :name => 'post_id_ix'	
  end
end
