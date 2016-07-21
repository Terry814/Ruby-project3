# Job to send all followups

require 'fuemail_helper'
require 'rubyrems/email_pattern'

include FuemailHelper

n = 0
err = 0

fu_set = AgentRemindersSetting.find(:first, :conditions => ["rem_type = ?", 'Customer Monthly'])
month = fu_set.month

puts "Sending followups for #{month}"

fus = CustomerFu.find(:all, :conditions => ["sent = ? and ignore_it = ? and month = ?", false, false, month], :limit => 50, :order => 'id')
fus.each do |fu|
  if fu.email_addr =~ RFC822::EmailAddress
    fup = make_fu(fu)
    Followup.deliver_customer(fup, true)     #  ==> set second parm to true to send to customers
    #puts "Sent: to  #{fup['email_addr']}"
    n += 1
    fu.sent = true
    fu.sent_at = Time.now
    fu.save
    cust = fu.customer
    cust.last_fu_at = Time.now
    cust.save
  else
    err += 1
    fu.ignore_it = true
    fu.save
  end
end

left = CustomerFu.find(:all, :conditions => ["sent = ? and ignore_it = ? and month = ?", false, false, month])

puts "#{n} emails sent; #{err} invalid addresses"
puts "#{left.size} followups still to be sent for #{month}"
