class AddMetaTgTaskDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_task_details, :meta, :json, default: {}
  end
end
