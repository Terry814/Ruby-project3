class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.string  :source,    :limit => 50
      t.string  :source_key
      t.string  :message_id
      t.string  :in_reply_to
      t.string  :subject
      t.string  :partinfo
      t.string  :direction, :limit => 10
      t.string  :bus_type, :limit => 50
      t.string  :from_addr
      t.text    :to_addr
      t.text    :bcc_addr
      t.text    :cc_addr
      t.text    :body
      t.string  :body_type, :limit => 10
      t.string  :fetch_key, :limit => 50
      t.string  :subject_cname
      t.string  :subject_aref, :limit => 100
      t.string  :subject_info
      t.string  :body_cname
      t.string  :body_aref, :limit => 100
      t.string  :clientemail
      t.string  :clientphone
      t.string  :agency, :limit => 100
      t.string  :region, :limit => 100
      t.string  :price, :limit => 100
      t.string  :inforeq
      t.string  :viewreq
      t.boolean :parsed
      t.boolean :ignore_parse
      t.boolean :matched
      t.boolean :ignore_match
      t.boolean :completed
      t.string  :error_str
      t.datetime :sent_at
      t.boolean :mortgage_info
      t.boolean :currency_info

      t.timestamps
    end
  end

  def self.down
    drop_table :emails
  end
end
