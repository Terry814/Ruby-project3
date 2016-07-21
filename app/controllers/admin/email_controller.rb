class Admin::EmailController < ApplicationController
  before_filter :login_required
  
  active_scaffold :email do |config|
    config.columns.add :cust_title, :cust_first_name, :cust_last_name, :property, :info
    config.list.columns = [:id, :source, :source_key, :sent_at, :cust_title, :cust_first_name,
        :cust_last_name, :property, :info, :to_addr, :bcc_addr, :parsed, :ignore,
        :completed, :created_at ]
  end
end