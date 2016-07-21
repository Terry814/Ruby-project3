class Admin::EnquiryController < ApplicationController
  before_filter :login_required
  
  active_scaffold :enquiry do |config|
    config.list.columns = [:id, :customer, :property, :received_at,
      :agent_enquiries, :unmatched_recipients]
    config.list.sorting = [:id => :asc]
    config.list.per_page = 25
    config.update.columns = [:property, :currency, :mortgage, :info, :viewing]
  end
end