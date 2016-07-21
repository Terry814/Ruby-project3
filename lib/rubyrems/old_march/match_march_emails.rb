$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..')
$:.unshift File.join(File.dirname(__FILE__), "../../app/models")

require 'rubygems'
require 'inc_models'

class ProcessEmails
  attr_reader :n, :matched, :unmatched, :new_cust, :new_enq, :in, :out, :custpres,
    :inenqpres, :outenqpres

  def initialize
    @in = 0
    @out = 0
    @n = 0
    @matched = 0
    @unmatched= 0
    @new_cust = 0
    @new_enq = 0
    @custpres = 0
    @inenqpres = 0
    @outenqpres = 0
  end

  def run 
    recs = Email.find(:all, 
      :conditions => ['source = "python" and matched = 0 and ignore_match = 0 and parsed = 1'],
      :order => 'id')
    @n = recs.size
    puts "Found #{@n} emails to match"

    recs.each {|@rec|
      @rec.parse_cust_name
      @dir = @rec.direction
      match_out_email
    }
  end

  # find or create customer
  def handle_cust
    email = @rec.clientemail

    # ignore if no customer email
    if email == nil
      @rec.ignore_match = true
      @rec.error_str = 'No customer email address'
      @rec.save
      return nil
    end

    email.strip!
    if email == ''
      @rec.ignore_match = true
      @rec.error_str = 'No customer email address'
      @rec.save
      return nil
    end

    # find customer or add
    cust = Customer.find_by_email(email)
    if cust == nil
      if @rec.clientphone != nil
        home = @rec.clientphone
        mobile = nil
        if home[0..1] == '07'
          mobile = home
          home = nil
        end
      else
        home = nil
        mobile = nil
      end

      cust = Customer.create(
        :email => email,
        :title => @rec.cust_tl,
        :first => @rec.cust_fs,
        :last => @rec.cust_ls,
        :phone_home => home,
        :phone_mobile => mobile,
        :active => true,
        :get_fu => true
      )
      @new_cust += 1
    else
      @custpres += 1
    end

    return cust
  end

  def match_out_email
    @out += 1

    # look for customer
    cust = handle_cust
    return if cust == nil

    # ignore it if back to customer
    return if @rec.to_addr == cust.email

    # look for relevant enquiry - if found just add out email info else create enquiry
    # watch for the same one already processed
    enq = nil
    enqs = Enquiry.find_all_by_customer_id_and_property(cust.id(), @rec.property, :order => 'received_at desc')
    if enqs.size > 0
      enq = enqs[0]
      enq.out_email_id = @rec.id() if enq.out_email_id == nil
      enq.save
      @outenqpres += 1
    else
      enq = Enquiry.create(
        :customer_id => cust.id(),
        :out_email_id => @rec.id(),
        :property => @rec.property,
        :info => @rec.info,
        :viewing => @rec.viewreq,
        :mortgage => @rec.mortgage_info,
        :currency => @rec.currency_info,
        :received_at => @rec.sent_at
      )
      @new_enq += 1
    end

    # now match agents
    agents, nf = Agent.find_agents(@rec.to_addr + ';' + @rec.bcc_addr)

    agents.each {|ag|
      age = AgentEnquiry.find_by_enquiry_id_and_agent_id_and_sent_at(enq.id(), ag.id(), @rec.sent_at)
      if age == nil
        AgentEnquiry.create(
          :enquiry_id => enq.id(),
          :agent_id => ag.id(),
          :sent_at => @rec.sent_at,
          :created_at => @rec.sent_at
        )
        @matched += 1
      end
    }

    nf.each {|s|
      umr = UnmatchedRecipient.find_by_enquiry_id_and_recipient_str(enq.id(), s)
      if umr == nil
        UnmatchedRecipient.create(
          :enquiry_id => enq.id(),
          :recipient_str => s
        )
        @unmatched += 1
      end
    }

    @rec.matched = true
    @rec.save
  end

end

if __FILE__ == $0
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
end
