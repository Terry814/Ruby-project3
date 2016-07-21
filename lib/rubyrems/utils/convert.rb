# Convert from old format with reminder_lines to new

startdate = Date.new(2010, 3, 1)
enddate = Date.new(2010, 6, 1)
month = "March 2010 - May 2010"

ae_set_cnt = 0
ae_ignore_cnt = 0

rems = AgentReminder.find_all_by_sent(true)
puts "Found #{rems.size} sent reminders"
rems.each { |rem|
  aes = rem.agent_enquiries.find(:all)
  aes.each {|ae|
  if ae.sent_at >= startdate and ae.sent_at < enddate
    ae.rem_sent = true
    ae.save
    ae_set_cnt += 1
  else
    ae_ignore_cnt += 1
  end
  }
  rem.month = month
  rem.save
}

puts "Done: set: #{ae_set_cnt}; ignored #{ae_ignore_cnt}"