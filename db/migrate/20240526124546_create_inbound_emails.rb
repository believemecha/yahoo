class CreateInboundEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :inbound_emails do |t|
      t.string :subject
      t.text :summary
      t.datetime :received_time
      t.text :content
      t.string :to_address
      t.string :from_address
      t.string :card_number
      t.string :otp
      t.json :meta, default: {}
      t.timestamps
    end
  end
end
