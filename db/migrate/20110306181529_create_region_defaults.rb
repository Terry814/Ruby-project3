class CreateRegionDefaults < ActiveRecord::Migration
  def self.up
    create_table :region_defaults do |t|
      t.string :region
      t.string :department
      t.integer :agent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :region_defaults
  end
end
