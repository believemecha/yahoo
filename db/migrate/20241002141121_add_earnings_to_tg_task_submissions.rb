class AddEarningsToTgTaskSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_task_submissions, :earning, :float
  end
end
