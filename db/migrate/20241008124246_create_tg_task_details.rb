class CreateTgTaskDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :tg_task_details do |t|
      t.integer :tg_task_id
      t.integer :tg_user_id
      t.text :details
      
      t.timestamps
    end
  end
end
