class CreateRawEnquiries < ActiveRecord::Migration
  def self.up
    create_table :raw_enquiries do |t|
      t.string :client_name
      t.string :client_email
      t.string :client_phone
      t.string :agent
      t.string :aref
      t.string :propid
      t.string :agent_mail
      t.string :price
      t.string :region
      t.string :department
      t.boolean :mortgage
      t.boolean :currency
      t.string  :viewing_info
      t.string  :info_req
      t.boolean :privad
      t.boolean :actioned

      t.timestamps
    end
  end

  def self.down
    drop_table :raw_enquiries
  end
end
