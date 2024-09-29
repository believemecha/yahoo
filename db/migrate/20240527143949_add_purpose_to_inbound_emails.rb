class AddPurposeToInboundEmails < ActiveRecord::Migration[7.0]
  def change
    add_column :inbound_emails, :purpose, :string
  end
end