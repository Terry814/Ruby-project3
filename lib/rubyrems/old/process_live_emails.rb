# read the live emails db and parse them into customers, enquiries, agent
# enquiries and unmatched agents 13/2/08

class ProcessLiveEmails
  attr_reader :matched, :unmatched, :new_cust, :new_enq
  
  def run() 
    @matched = 0
    @unmatched= 0
    @new_cust = 0
    @new_enq = 0
    
    recs = LiveEmail.find_all_by_parsed_and_enq_type(false, 'first-info') 
    recs.each {|r| parse_first_info(r)}
  end

  def parse_first_info(rec)
    agent = rec.body =~ /agent:(.*)propertyref:/m ? $1.chomp.strip.chomp.strip : ''
    prop = rec.body =~ /propertyref:(.*)name:/m ? $1.chomp.strip.chomp.strip : ''
    name = rec.body =~ /name:(.*)telephone:/m ? $1.chomp.strip.chomp.strip : ''
    phone = rec.body =~ /telephone:(.*)clientemail:/m ? $1.chomp.strip.chomp.strip : '' 
    email = rec.body =~ /clientemail:(.*)inforequest:/m ? $1.chomp.strip.chomp.strip : ''
    mortgage = rec.body =~ /mortgagerequest:(.*)currencyexchange:/m ? $1.chomp.strip.chomp.strip : ''
    currency = rec.body =~ /currencyexchange:(.*)b1:/m ? $1.chomp.strip.chomp.strip : ''
    info = rec.body =~ /inforequest:(.*)viewinginfo:/m ? $1.chomp.strip.chomp.strip : ''
    
    view = $1.chomp.strip.chomp.strip if rec.body =~ /viewinginfo:(.*)mortgagerequest:/m
    view = $1.chomp.strip.chomp.strip if rec.body =~ /viewinginfo:(.*)b1:/m and not view
    view = '' if not view
    
    info.gsub!('Please SPECIFY the information you require .....', '')
    view.gsub!('Please arrange a viewing on date / time:', '')
      
    if mortgage == 'ON'
      mortgage = true
    else
      mortgage = false
    end 
        
    if currency == 'ON'
      currency = true
    else
      currency = false
    end
    
    cust = Customer.find_by_email(email)
    
    if not cust
      home = phone
      mobile = ''
      if home[0..1] == '07'
        mobile = home
        home = ''
      end
    
      els = Customer.split_name(name)
      
      cust = Customer.create(
        :email => email,
        :title => els[0],
        :first => els[1],
        :last => els[2],
        :phone_home => home,
        :phone_mobile => mobile,
        :active => true,
        :get_fu => true
      )
      @new_cust += 1
    end
    
    enq = Enquiry.find_by_customer_id_and_property_and_received_at(cust.id,
      prop, rec.delivery_date)
    
    if not enq
      enq = Enquiry.create(
        :customer_id => cust.id,
        :property => prop,
        :received_at => rec.delivery_date,
        :created_at => Time.now
      )
      @new_enq += 1
    
    
      agents, nf = Agent.find_agents(rec.to_addr + ';' + rec.bcc_addr)
    end
   
    # #rec.parsed = true #rec.save
  end  
end

# #if __FILE__ == $0
imp = ProcessLiveEmails.new
imp.run()
puts "New Customers: #{imp.new_cust}"
puts "New Enquiries: #{imp.new_enq}"
puts "Matched Agents: #{imp.matched}"
puts "Unmatched recipients: #{imp.unmatched}"
# #end
