class CreateTgTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tg_tasks do |t|
      t.float :cost
      t.string :name
      t.text :description
      t.integer :status
      t.integer :submission_type
      t.datetime :start_time
      t.datetime :end_time
      t.string :links, array: true, default: []
      t.string :code

      t.timestamps
    end
  end
  
  def down
    drop_table :tg_tasks
  end
end
