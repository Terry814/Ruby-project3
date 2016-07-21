class Admin::AgentReminderController < ApplicationController
  before_filter :login_required

  active_scaffold :agent_reminder do |config|
    config.list.columns = [:rem_id, :agent, :rem_type, :month, :rem_count, :email_addr, :subject, :greeting, :preamble, :postamble,
      :signoff, :signature, :sent, :ignore_it, :agent_enquiries ]
    config.show.columns = [:rem_id, :agent, :rem_type, :month, :rem_count, :email_addr, :subject, :greeting, :preamble, :postamble,
      :signoff, :signature, :sent, :ignore_it, :agent_enquiries ]
  end

  def conditions_for_collection
    ['rem_count > 0 and sent = 0 and rem_type = "monthly"']
  end

end
