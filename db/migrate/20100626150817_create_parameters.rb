class CreateParameters < ActiveRecord::Migration
  def self.up
    create_table :parameters do |t|
      t.date :last_inbox_email_load_date
      t.date :last_sent_email_load_date
      t.timestamps
    end
  end

  def self.down
    drop_table :parameters
  end
end
