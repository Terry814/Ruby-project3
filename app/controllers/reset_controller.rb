class ResetController < ApplicationController

  before_filter :login_required

  def empty_emails
    ActiveRecord::Base.connection.execute('truncate table emails')
    render :text => "Emptied emails"
  end

  def revert_emails
    n = Email.update_all("parsed = false, ignore_parse = false, matched = false, ignore_match = false")
    render :text => "Set #{n} emails to unprocessed"
  end

  def back_to_start
    ActiveRecord::Base.connection.execute('truncate table agent_reminder_lines')
    ActiveRecord::Base.connection.execute('truncate table agent_reminders')
    ActiveRecord::Base.connection.execute('truncate table agent_enquiries')
    ActiveRecord::Base.connection.execute('truncate table unmatched_recipients')
    ActiveRecord::Base.connection.execute('truncate table enquiries')
    ActiveRecord::Base.connection.execute('truncate table customers')
    render :text => 'Processing tables truncated'
  end

  def reset_agent_enqs
    ActiveRecord::Base.connection.execute('update agent_enquiries set rem_created = 0, agent_reminder_id = null')
    render :text => "Reset agent enquiries"
  end

  def empty_reminders
    ActiveRecord::Base.connection.execute('truncate table agent_reminder_lines')
    ActiveRecord::Base.connection.execute('truncate table agent_reminders')
    render :text => 'Reminders tables truncated'
  end

  def empty_agents
    ActiveRecord::Base.connection.execute('truncate table agents')
    render :text => 'Agent table truncated'
  end
  
end