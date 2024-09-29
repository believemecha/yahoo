class AddMetaToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :meta, :json, default: {}
  end
end
