class CreateTgUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :tg_users do |t|
      t.integer :chat_id
      t.string :name
      t.boolean :blocked
      
      t.timestamps
    end
  end
end
