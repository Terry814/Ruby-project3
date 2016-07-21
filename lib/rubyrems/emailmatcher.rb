# process the emails to customers, enquiries etc
# Finds all email where source is not 'python', parsed is true, matched is false and ignore_match is false
# Calls the email.parse_cust_name function for all, sets ignore_match if no customer email
# handle 'in' and 'out' differently
# 'in' -  find or create customer, find or create enquiry by customer, property and received_at
# 'out' - find or create customer, find or create enquiry by customer and property,
#   split agents into found and not_found, create agent enquiry if not already there
#   save not found for further work if not already there
# set matched
# 25/5/10
# 9/10/10 added update of cust_last_enq_date
# 21/10/10 amended to handle ones sent to customer with agent in bcc
# 1/12/10 added line to use cc_addr for clientemail if its an out email

class ProcessEmails
  attr_reader :n, :matched, :unmatched, :new_cust, :new_enq, :in, :out, :custpres,
    :inenqpres, :outenqpres, :no_cust

  def initialize
    @no_cust = 0
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
      :conditions => ['source != "python" and matched = 0 and ignore_match = 0 and parsed = 1'],
      :order => 'id')
    @n = recs.size
    puts "Found #{@n} emails to match"

    recs.each {|@rec|
      @rec.parse_cust_name
      @dir = @rec.direction
      if @dir == 'out'
        match_out_email
      elsif @dir == 'in'
        match_in_email
      else
        puts 'Unknown mail direction'
      end
    }
  end

  # find or create customer
  # set ignore match if no customer email
  def handle_cust
    email = @rec.clientemail

    # if email is nil and this is an out email try cc_addr for email
    if email == nil and @dir == 'out'
      email = @rec.cc_addr
    end

    # ignore if no customer email
    if email == nil
      @rec.ignore_match = true
      @rec.error_str = 'No customer email address'
      @rec.save
      @no_cust += 1
      return nil
    end

    email.strip!
    if email == ''
      @rec.ignore_match = true
      @rec.error_str = 'No customer email address'
      @rec.save
      @no_cust += 1
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
        :firstname => @rec.cust_fs,
        :lastname => @rec.cust_ls,
        :phone_home => home,
        :phone_mobile => mobile,
        :active => true,
        :gets_fu => true
      )
      @new_cust += 1
    else
      @custpres += 1
    end

    return cust
  end

  def update_cust_last_enq(cust, enqdate)
    if cust.last_enq_date == nil or enqdate > cust.last_enq_date
      cust.last_enq_date = enqdate
      cust.save
    end
  end

  def match_in_email
    @in += 1

    cust = handle_cust
    return if cust == nil

    # look for an enquiry for this customer, property and date
    # if found then nothing to do
    enq = Enquiry.find_by_customer_id_and_property_and_received_at(cust.id(), @rec.property, @rec.sent_at)
    if enq == nil
      enq = Enquiry.create(
        :customer_id => cust.id(),
        :in_email_id => @rec.id(),
        :property => @rec.property,
        :region => @rec.region,
        :info => @rec.info,
        :viewing => @rec.viewreq,
        :mortgage => @rec.mortgage_info,
        :currency => @rec.currency_info,
        :received_at => @rec.sent_at
      )
      @new_enq += 1
    else
      @inenqpres += 1
    end

    update_cust_last_enq(cust, @rec.sent_at) if @rec.sent_at != nil

    @rec.matched = true
    @rec.save
  end

  def match_out_email
    @out += 1

    agt_str = ""
    # look for customer
    cust = handle_cust
    return if cust == nil

    # look for relevant enquiry - if found just add out email info else create enquiry
    # watch for the same one already processed
    enq = nil
    enqs = Enquiry.find_all_by_customer_id_and_property(cust.id(), @rec.property, :order => 'received_at desc')
    if enqs.size > 0
      enq = enqs[0]
      enq.out_email_id = @rec.id() if enq.out_email_id == nil or enq.out_email_id == 0
      enq.save
      @outenqpres += 1
    else
      enq = Enquiry.create(
        :customer_id => cust.id(),
        :out_email_id => @rec.id(),
        :property => @rec.property,
        :region => @rec.region,
        :info => @rec.info,
        :viewing => @rec.viewreq,
        :mortgage => @rec.mortgage_info,
        :currency => @rec.currency_info,
        :received_at => @rec.sent_at
      )
      @new_enq += 1
    end

    update_cust_last_enq(cust, @rec.sent_at) if @rec.sent_at != nil

    # now match agents

    # pick up agents to search for
    if @rec.to_addr == cust.email
      agt_str = @rec.bcc_addr
    else
      agt_str = @rec.to_addr + ';' + @rec.bcc_addr
    end

    # find agents checks for blank or nil
    agents, nf = Agent.find_agents(agt_str)

    # dont create if already there
    agents.each {|ag|
      age = AgentEnquiry.find_by_enquiry_id_and_agent_id_and_sent_at(enq.id(), ag.id(), @rec.sent_at)
      if age == nil
        AgentEnquiry.create(
          :enquiry_id => enq.id(),
          :agent_id => ag.id(),
          :sent_at => @rec.sent_at
        )
        @matched += 1
      end
    }

    # dont create if already there
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