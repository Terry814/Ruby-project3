# run the reminders creation

require 'rubyrems/fucreator'

pr = FuCreator.new
pr.run
puts "Done Follow-ups #{pr.fu_cnt}, lines: #{pr.enq_cnt}, not used #{pr.oop_cnt}"