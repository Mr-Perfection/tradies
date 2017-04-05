class AddPaymentMethodToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :payment_method, :string
  end
end
