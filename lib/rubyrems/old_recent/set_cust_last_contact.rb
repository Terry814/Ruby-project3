# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__), '..')

require 'inc_models'

custs = Customer.find(:all)
n = 0
custs.each {|c|
  n += 1  
  c.enquiries.each {|e|
     if e.received_at != nil
       if c.last_enq_date == nil or e.received_at > c.last_enq_date
         c.last_enq_date = e.received_at
         c.save
       end
     end
  }
}

puts "done: #{n}"