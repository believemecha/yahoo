class CreateKeyValueStores < ActiveRecord::Migration[7.0]
  def change
    create_table :key_value_stores do |t|
      t.string :key
      t.string :value 
      t.timestamps
    end
  end
end
