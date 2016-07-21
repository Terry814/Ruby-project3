class CreateAgentReminders < ActiveRecord::Migration
  def self.up
    create_table :agent_reminders do |t|
      t.integer :agent_id
      t.string  :month,    :limit => 100
      t.string  :rem_type,    :limit => 20
      t.integer :ren_count
      t.string  :email_addr,    :limit => 100
      t.string  :subject
      t.string  :greeting
      t.string  :preamble
      t.string  :postamble
      t.string  :signoff
      t.string  :signature
      t.boolean :ignore_it,     :default => 0
      t.boolean :sent,          :default => 0
      t.datetime :sent_at
      t.timestamps
    end
    
    execute "alter table agent_reminders 
               add constraint fk_agent_reminder_agent 
               foreign key (agent_id) references agents(id)"
  end

  def self.down
    drop_table :agent_reminders
  end
end
