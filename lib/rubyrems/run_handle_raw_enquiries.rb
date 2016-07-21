# run the raw enquiries
require 'rubygems'
require 'rubyrems/handle_enquiries'

eh = EnquiryHandler.new
eh.run(:all)

puts "Total enquires: #{eh.total_enqs}, Currency Emails: #{eh.currency_emails}, " +
  "Mortgage Emails: #{eh.mortgage_emails}, Private Emails: #{eh.private_emails}, " +
  "Bargain Emails: #{eh.bargain_emails}, Spam ignored: #{eh.spam_enqs}"