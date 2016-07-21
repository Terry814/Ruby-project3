# run the reminders creation

require 'rubyrems/reminderscreator'

pr = RemindersCreator.new()
pr.run
puts "Done. New Reminders: #{pr.new_ar_cnt}, Existing: #{pr.exist_ar_cnt}; Enquiry lines: #{pr.ae_cnt}, not used enquiries: #{pr.oop_cnt}"