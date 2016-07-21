class Admin::RawEnquiriesController < ApplicationController
  before_filter :login_required
  
  active_scaffold :raw_enquiries do |config|
    config.list.columns = [:raw_enq_id, :client_name, :client_email, :client_phone, :agent, :aref, :propid, :agent_email,
      :region, :department, :price, :mortgage, :currency, :privad, :viewing_info, :info_req, :ignore_it, :currency_sent, :mortgage_sent,
      :private_client_sent, :private_agent_sent, :private_agent_earlyad_sent, :bargain_client_sent, :bargain_agent_sent, :err_msg, :warn_msg, :actioned]
    config.list.sorting = [:id => :desc]
    config.update.columns = [:client_name, :client_email, :client_phone, :agent, :aref, :propid, :agent_email,
      :region, :department, :price, :mortgage, :currency, :privad, :viewing_info, :info_req, :ignore_it, :currency_sent, :mortgage_sent,
      :private_client_sent, :private_agent_sent, :private_agent_earlyad_sent, :bargain_client_sent, :bargain_agent_sent, :err_msg, :warn_msg, :actioned]
    config.create.columns = [:client_name, :client_email, :client_phone, :agent, :aref, :propid, :agent_email,
      :region, :department, :price, :mortgage, :currency, :privad, :viewing_info, :info_req, :ignore_it ]
  end
  
  def conditions_for_collection
    ['actioned = false']
  end
end