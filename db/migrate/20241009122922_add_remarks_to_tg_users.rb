class AddRemarksToTgUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_users, :remarks, :string
  end
end
