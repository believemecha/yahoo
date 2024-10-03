class ChangeChatIdToStringInYourTableName < ActiveRecord::Migration[7.0]
  def change
    change_column :tg_users, :chat_id, :string
  end
end
