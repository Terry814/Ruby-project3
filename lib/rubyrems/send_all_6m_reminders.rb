# Job to send all reminders

require 'rememail_helper'

include RememailHelper
n = 0

rem_set = AgentRemindersSetting.find_by_rem_type('Agent Six-monthly')
rems = AgentReminder.find(:all, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'six-monthly', rem_set.month, 0, false, false])

rems.each do |rem|
  reminder = make_reminder(rem)
  if reminder['lines'].size > 0
    begin
    	Reminder.deliver_agent(reminder, true)      #  ==> set second parm to true to send to agents
    	puts "Sent: #{reminder['lines'].size} lines to  #{reminder['email_addr']}"
    	n += 1
    	rem.sent = true
    	rem.sent_at = Time.now
    	rem.save
    	rem.agent_6m_enquiries.update_all :rem_6m_sent => true
    rescue SocketError
    	puts "Could not send to #{reminder['email_addr']}, due to #{$!}"
    end
  end
end

puts "#{n} emails sent"
