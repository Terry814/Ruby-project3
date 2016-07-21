class CreateAgents < ActiveRecord::Migration
  def self.up
    create_table :agents do |t|
      t.string :email1
      t.string :email2
      t.string :email3
      t.string :firstname
      t.string :lastname
      t.string :name1
      t.string :name2
      t.string :name3
      t.string :categories
      t.string :priority
      t.string :phone_home
      t.string :phone_mobile
      t.string :phone_bus
      t.string :phone_bus2
      t.string :fax
      t.string :company
      t.string :job_title
      t.string :address_home
      t.boolean :active
      t.string  :source
      t.boolean :get_rem
      t.boolean :get_6m_rem
      t.date    :last_rem_date
      t.date    :last_6m_rem_date
      t.text    :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :agents
  end
end
