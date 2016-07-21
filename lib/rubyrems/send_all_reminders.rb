# Job to send all reminders

require 'rememail_helper'

include RememailHelper
n = 0

rem_set = AgentRemindersSetting.find_by_rem_type('Agent Monthly')
rems = AgentReminder.find(:all, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ? ', 'monthly', rem_set.month, 0, false, false])

rems.each do |rem|
  reminder = make_reminder(rem)
  if reminder['lines'].size > 0
    Reminder.deliver_agent(reminder, true)      #  ==> set second parm to true to send to agents
    puts "Sent: #{reminder['lines'].size} lines to  #{reminder['email_addr']}"
    n += 1
    rem.sent = true
    rem.sent_at = Time.now
    rem.save
    rem.agent_enquiries.update_all :rem_sent => true
  end
end

puts "#{n} emails sent"