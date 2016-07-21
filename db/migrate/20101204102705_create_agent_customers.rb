class CreateAgentCustomers < ActiveRecord::Migration
  def self.up
    create_table :agent_customers do |t|
      t.integer :customer_id
      t.integer :agent_id
      t.boolean :active
      t.string :source
      t.notes :text
      
      t.timestamps
    end

    execute "alter table agent_customers
               add constraint fk_agent_customer_customer
               foreign key  (customer_id) references customers(id)"

    execute "alter table agent_customers
               add constraint fk_agent_customer_agent
               foreign key  (agent_id) references agents(id)"

  end



  def self.down
    drop_table :agent_customers
  end
end
