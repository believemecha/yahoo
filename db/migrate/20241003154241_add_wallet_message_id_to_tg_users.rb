class AddWalletMessageIdToTgUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_users, :wallet_message_id, :integer
  end
end
