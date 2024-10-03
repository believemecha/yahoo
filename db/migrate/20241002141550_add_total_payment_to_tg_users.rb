class AddTotalPaymentToTgUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_users, :total_earning, :float
    add_column :tg_users, :wallet_address, :string
  end
end
