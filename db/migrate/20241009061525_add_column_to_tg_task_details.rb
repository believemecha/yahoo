class AddColumnToTgTaskDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_task_details, :custom_data, :string
  end
end


