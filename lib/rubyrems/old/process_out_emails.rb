# import some emails and parse them into customers, enquiries, agent enquiries
# and unmatched agents 13/2/08

# TODO workout how this will be run
# TODO remember to include the test for 'invoice' and others in the python ver
from  = '2007-01-01' 
to    = '2007-01-05'

class ProcessOutEmails
  attr_reader :n, :matched, :unmatched, :new_cust, :new_enq
  
  def run(from, to) 
    @from = from
    @to = to
    
    @n = 0
    @matched = 0
    @unmatched= 0
    @new_cust = 0
    @new_enq = 0
    
    recs = Email.find(:all, 
      :conditions => ['sent_at >= ? and sent_at < ? and parsed = 0 and `ignore` = 0', @from, @to ],
      :order => 'id')
    @n = recs.size
    recs.each {|r| parse_one_email(r)}
  end

  def parse_one_email(rec)
    email = rec.cust_email
    if email == nil
      rec.ignore = true
      rec.error_str = 'No customer email address'
      rec.save
      return
    end

    email.strip!
    if email == ''
      rec.ignore = true
      rec.error_str = 'No customer email address'
      rec.save
      return
    end

    cust = Customer.find_by_email(email)
    if cust == nil
      home = rec.cust_phone
      mobile = nil
      if home[0..1] == '07'
        mobile = home
        home = nil
      end
    
      cust = Customer.create(
        :email => email,
        :title => rec.cust_title,
        :first => rec.cust_first_name,
        :last => rec.cust_last_name,
        :phone_home => home,
        :phone_mobile => mobile,
        :active => true,
        :get_fu => true
      )
      @new_cust += 1
    end
    
    # look for an enquiry for this customer, property and date
    # if found then not only the enquiry but also the agent_enquiry and the 
    # unmatched addresses should have been created
    enq = Enquiry.find_by_customer_id_and_property_and_received_at(cust.id(), rec.property, rec.sent_at)
    if enq == nil
      enq = Enquiry.create(
        :customer_id => cust.id(),
        :email_id => rec.id(),
        :property => rec.property,
        :received_at => rec.sent_at,
        :created_at => rec.stored_at
      )
      @new_enq += 1
        
      agents, nf = Agent.find_agents(rec.to_addr + ';' + rec.bcc_addr)
    
      agents.each {|ag|
        AgentEnquiry.create(
          :enquiry_id => enq.id(),
          :agent_id => ag.id(),
          :created_at => rec.stored_at
        )
        @matched += 1
      }
    
      nf.each {|s|
        UnmatchedRecipient.create(
          :enquiry_id => enq.id(),
          :recipient_str => s
        )
        @unmatched += 1
      }
    end
    
    rec.parsed = true
    rec.save
  end  
end

if __FILE__ == $0
  imp = ProcessOutEmails.new
  imp.run(from, to)
  puts "New Customers: #{imp.new_cust}"
  puts "New Enquiries: #{imp.new_enq}"
  puts "Matched Agents: #{imp.matched}"
  puts "Unmatched recipients: #{imp.unmatched}"
end
