class Admin::AgentEnquiryController < ApplicationController
  before_filter :login_required
  
  active_scaffold :agent_enquiry do |config|
    config.list.columns = [:id, :enquiry, :agent, :enq_type, :agent_reminder, :sent_at]
    config.list.sorting = [:id => :asc]
  end
  
  def conditions_for_collection
    ['agent_enquiries.ignore_it = 0']
  end
end