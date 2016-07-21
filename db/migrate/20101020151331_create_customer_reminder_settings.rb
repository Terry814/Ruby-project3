class CreateCustomerReminderSettings < ActiveRecord::Migration
  def self.up
    create_table :customer_reminder_settings do |t|
      t.string :fu_type,  :limit => 100
      t.string :month
      t.string :subject
      t.string :greeting
      t.string :preamble
      t.string :preregions
      t.string :postamble
      t.string :signoff
      t.string :signature
      t.date   :from_date
      t.date   :to_date
      t.timestamps
    end

    CustomerReminderSetting.create(
      :fu_type => 'monthly',
      :month => "October 2010",
      :subject => '1st-for-french-property - Courtesy Contact',
      :greeting => 'Dear %s',
      :preamble => 'You have recently contacted us about an overseas property',
      :preregions => 'For your convenience these are links to the region pages you were interested in - on these pages you will find our latest properties for the region:',
      :postamble => 'As usual please let us know the progress of any existing sales or new sales - client name, property ref, sale price and estimated completions date.',
      :signoff => 'Thank you.',
      :signature => 'Howard - 1st-for-french-property.co.uk',
      :from_date => "2010-10-01",
      :to_date => "2010-10-31"
    )
  end

  def self.down
    drop_table :customer_reminder_settings
  end
end
