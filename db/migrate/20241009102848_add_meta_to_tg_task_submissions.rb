class AddMetaToTgTaskSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_task_submissions, :meta, :json, default: {}
  end
end
