class CreateAgentEnquiries < ActiveRecord::Migration
  def self.up
    create_table  :agent_enquiries do |t|
      t.integer   :enquiry_id
      t.integer   :agent_id
      t.datetime  :sent_at
      t.integer   :agent_reminder_id
      t.boolean   :rem_sent,       :default => 0
      t.integer   :agent_reminder_6m_id
      t.boolean   :rem_6m_sent,       :default => 0
      t.string    :enq_type
      t.boolean   :ignore_it, :default => 0
      t.timestamps
    end
    
    execute "alter table agent_enquiries 
               add constraint fk_agent_enquiry_enquiry 
               foreign key  (enquiry_id) references enquiries(id)"
    
    execute "alter table agent_enquiries 
               add constraint fk_agent_enquiry_agent 
               foreign key (agent_id) references agents(id)"
    
  end

  def self.down
    drop_table :agent_enquiries
  end
end
