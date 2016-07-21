class CreateCustomerFus < ActiveRecord::Migration
  def self.up
    create_table :customer_fus do |t|
      t.integer :customer_id
      t.string  :month,    :limit => 100
      t.string  :fu_type,    :limit => 20
      t.integer :fu_count
      t.string  :email_addr,    :limit => 100
      t.string  :subject
      t.string  :greeting
      t.string  :preamble
      t.string  :preregions
      t.string  :postamble
      t.string  :signoff
      t.string  :signature
      t.boolean :ignore_it,     :default => 0
      t.boolean :sent,          :default => 0
      t.datetime :sent_at
      t.timestamps
    end

    execute "alter table customer_fus
               add constraint fk_customer_fu_custoner
               foreign key (customer_id) references customers(id)"
  end

  def self.down
    drop_table :customer_fus
  end
end
