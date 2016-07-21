$:.unshift File.join(File.dirname(__FILE__), "..")

require 'inc_models'

ag = Agent.find(216) #216 live, 83 local
of = File.open('clives_enquiries.txt', 'w')
of.write "Customer                                           Email                                              Property                       Sent At   Rem Sent\n\n"

ag_enqs = ag.agent_enquiries.find(:all, :order => 'sent_at')

ag_enqs.each {|ae|
  enq = ae.enquiry
  cust = enq.customer
  ae_tm = ae.sent_at.strftime('%d/%m/%y')
  rem = ae.agent_reminder
  
  rm_tm = ""
  rm_tm = rem.sent_at.strftime('%d/%m/%y') if rem != nil and rem.sent_at != nil

  of.write sprintf("%-50.50s %-50.50s %-30.30s %s %s\n", cust, cust.email, enq.property, ae_tm, rm_tm)
}

of.close

puts "done"