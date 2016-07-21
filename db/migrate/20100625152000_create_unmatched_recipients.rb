class CreateUnmatchedRecipients < ActiveRecord::Migration
  def self.up
    create_table :unmatched_recipients do |t|
      t.integer :enquiry_id
      t.string  :recipient_str
      t.boolean :ignore_it,      :default => 0
      t.timestamps
    end
    
    execute "alter table unmatched_recipients
               add constraint fk_unmatched_recipient_enquiry 
               foreign key  (enquiry_id) references enquiries(id)"
  end

  def self.down
    drop_table :unmatched_recipients
  end
end
