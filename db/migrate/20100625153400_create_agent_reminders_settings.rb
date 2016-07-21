class CreateAgentRemindersSettings < ActiveRecord::Migration
  def self.up
    create_table :agent_reminders_settings do |t|
      t.string :rem_type,  :limit => 100
      t.string :month
      t.string :subject
      t.string :greeting
      t.string :preamble
      t.string :preregions
      t.string :body
      t.string :rpt_body
      t.string :postamble
      t.string :signoff
      t.string :signature
      t.date   :from_date
      t.date   :to_date
      t.timestamps
    end
  end

  def self.down
    drop_table :agent_reminders_settings
  end
end
