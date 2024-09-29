class CreateTgTaskSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :tg_task_submissions do |t|
      t.integer :tg_task_id
      t.integer :tg_user_id
      t.integer :status
      t.integer :submission_type
      t.text :description
      t.string :uploaded_files, array: true, default: []

      t.timestamps
    end
  end
  
  def down
    drop_table :tg_task_submissions
  end
end
