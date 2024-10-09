class AddCustomColumnsToTgTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_tasks, :custom_fields, :string, array: true, default: []
    add_column :tg_tasks, :custom_field_values, :json, default: {}
  end
end
