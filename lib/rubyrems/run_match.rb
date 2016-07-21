# run the email matcher

load 'rubyrems/emailmatcher.rb'

imp = ProcessEmails.new
imp.run
puts "In emails: #{imp.in}"
puts "Out emails: #{imp.out}"
puts "Existing Customers: #{imp.custpres}"
puts "New Customers: #{imp.new_cust}"
puts "New Enquiries: #{imp.new_enq}"
puts "Existing in Enquiries: #{imp.inenqpres}"
puts "Existing out Enquiries: #{imp.outenqpres}"
puts "Matched Agents: #{imp.matched}"
puts "Unmatched recipients: #{imp.unmatched}"
