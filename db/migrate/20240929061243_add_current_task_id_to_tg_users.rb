class AddCurrentTaskIdToTgUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :tg_users, :current_task_id, :integer
    add_column :tg_users, :submission_step, :string
    add_column :tg_users, :last_prompt_message_id, :integer
    add_column :tg_users, :code, :string
  end
end
