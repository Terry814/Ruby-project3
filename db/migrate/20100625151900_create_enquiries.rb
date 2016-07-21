class CreateEnquiries < ActiveRecord::Migration
  def self.up
    create_table :enquiries do |t|
      t.integer :customer_id
      t.integer :in_email_id
      t.integer :out_email_id
      t.string  :property
      t.string  :region, :limit => 100
      t.string  :info
      t.string  :viewing
      t.boolean :mortgage
      t.boolean :currency
      t.text    :notes
      t.datetime :received_at
      t.integer :customer_fu_id
      t.boolean :fu_sent,     :default => 0
      t.boolean :ignored_it,     :default => 0
      t.timestamps
    end
    
    execute "alter table enquiries 
               add constraint fk_enquiry_customer 
               foreign key  (customer_id) references customers(id)"

    execute "alter table enquiries
               add constraint fk_enquiry_in_email
               foreign key  (in_email_id) references emails(id)"

    execute "alter table enquiries
               add constraint fk_enquiry_out_email
               foreign key  (out_email_id) references emails(id)"
  end

  def self.down
    drop_table :enquiries
  end
end
