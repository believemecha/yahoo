class AddIsPrivateToTgTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_tasks, :is_private, :boolean, default: :false
  end
end
