class AddColumnsToTables < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_tasks, :maximum_per_user, :integer
    add_column :tg_tasks, :minimum_gap_in_hours, :integer
    add_column :tg_task_submissions, :code, :string

    add_column :tg_task_submissions, :is_paid, :boolean, default: false
  end
end
