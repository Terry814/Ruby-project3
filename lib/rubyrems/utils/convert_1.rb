# Convert from old format with reminder_lines to new

rems = AgentReminder.find_all_by_sent(true)
puts "Found #{rems.size} sent reminders"
rems.each { |rem|
  aes = rem.agent_enquiries.find(:all)
  rem.rem_count = aes.size
  rem.save
}

puts "Done"
