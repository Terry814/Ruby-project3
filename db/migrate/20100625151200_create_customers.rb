class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :email
      t.string :alt_email
      t.string :title
      t.string :firstname
      t.string :lastname
      t.string :phone_home
      t.string :phone_mobile
      t.boolean :active
      t.boolean :gets_fu,     :default => 1
      t.datetime :last_fu_at
      t.datetime :last_enq_date
      t.text :fu_data
      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
