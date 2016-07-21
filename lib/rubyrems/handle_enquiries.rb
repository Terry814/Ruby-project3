# Job handle incoming enquiries direct from fffp
# 28/1/11 v0.1
# 28/3/11 v0.2  - amended to lookup agents from propid in relm db
# 30/3/11 v0.3  - reverted to using Agent Name
# 30/3/11 v0.4  - logging and better error handling
# 18/4/11 v0.5  - added check for agent_email to privad
# 21/4/11 v0.55 - added capitalization to customer name
# 28/4/11 v0.6  - added check to not send currency or mortgage if previous
#                  in last 28 days added new field warn_msg to raw-enquiries added
#                  setting logger level and added some more log messages
# 28/4/11 v0.65 - fixed issue with aref/propid for privads
# 7/5/11  v0.7  - added exception handling around the sends, and temp fix for spam
# 9/5/11  v0.75 - minor change to spam regex
# 9/5/11  v0.8  - Added ignore_it to raw enquiries and amended read conditions
#               - Added check if early ad sent in last 28 days
#               - Added reply-to to emails
#               - Changed to new record driven spam checks
#               - Capitalized private advertiser name
# 20/5/11 v0.81 - Added line to log the parms settings - also swapped setup_log and get_user_parms
# 6/6/11  v0.82 - Moved clearing of agent etc to right place
# 20/6/11 v0.83 - Fixed error with high/low mortgage email selection
# 10/6/11 v0.90 - Added bargain limit and bargain template for each agent
# 21/6/11 v0.91 - Added template to agentremindersettings and also to use it in bargain_client emails
# 6/7/11  v0.92 - Fixed error introduced by individual bargain limits.
# 6/7/11  v0.93 - Add email if missing agent
# 6/7/11  v0.94 - Added log.close
# 5/11/11 v0.95 - Fixed bargain email template bug

#TODO do summary email to Louisa

require 'net/smtp'


class AuditLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
end

class EnquiryHandler
  attr_accessor :cagent, :magent, :total_enqs, :agent_emails, :currency_emails, 
    :mortgage_emails, :bargain_emails, :private_emails, :manual_emails, :spam_enqs

  def initialize
    setup_log
    
    get_user_parms

    @cagent = get_currency_agent
    @magent = get_mortgage_agent
    
    get_default_email_settings

    @total_enqs = 0
    @agent_emails = 0
    @currency_emails = 0
    @mortgage_emails = 0
    @bargain_emails = 0
    @private_emails = 0
    @manual_emails = 0
    @spam_enqs = 0
    @saved_mail = []

    td = Date.today
    @one_month_ago = td - 28
  end

  def run(rectype = :all, id = nil )
    # check for currency agent
    if not @cagent
      msg = "could not find currency agent" 
      @log.error msg
      puts msg
      return
    end

    #check for mortgage agent
    if not @magent 
      msg = "could not find mortgage agent" 
      @log.error msg
      puts msg
      return
    end
    
    @enqs = nil

    # read all or just one by id
    case rectype
    when :all
      @enqs = RawEnquiry.find(:all, :conditions => ['actioned = ? and ignore_it = ?', false, false], :order => 'id' )
      @log.debug "Doing all outstanding enquiries"
    when :single
      @enqs = RawEnquiry.find_all_by_id(id)
      @log.debug "Doing single enquiry"
    end

    @total_enqs = @enqs.size

    @log.info "Found #{@enqs.size} enquiries to process"

    # process them all
    @enqs.each_with_index {|@e, j|
      @i = j + 1
      @e.err_msg = ""
      @e.warn_msg = ""
      @error = false

      @cust = nil
      @enq = nil
      @agent = nil
      @agent_bargain_limit = nil
      @default_agent = nil
      @data = nil
      @ischeap = false
      @price = nil

      @template = "email"

      # cleanup the price
      stripped_price = @e.price.gsub(',', "")
      @price = (stripped_price).to_i
      
      get_default_agent if @e.region != nil or @e.department != nil

      # if not a privad then get agent related info
      if @e.privad == false
        @agent = get_agent(@e.agent)
        @agent_bargain_limit = @agent.bargain_limit if @agent   # v0.92 fix
        test_for_cheap
      end

      @reglink = get_link(@e.region) if @e.region != nil

      # common data
      @data = {
        :client_email => @e.client_email,
        :client_name => capitalize_str(@e.client_name),
        :client_phone => @e.client_phone,
        :price => @e.price,
        :region => @e.region,
        :dept => @e.department,
        :reglink => @reglink,
        :cagent =>  @cagent,
        :magent => @magent,
        :enqdata => make_enq_data,
        :enq_id => @e.id            #v0.93
      }

      # data for just privad or bargain
      if @e.privad == true
        @data[:advertiser_email] = @e.agent_email
        @data[:advertiser_name] = capitalize_str(@e.agent)
        @data[:propid] = @e.propid
      else
        @data[:agent_email] = @agent.email1 if @agent
        @data[:agent_name] = @e.agent
        @data[:aref] = @e.aref
        @data[:agent] = @agent if @agent
      end
      
      @data[:defagent] = @default_agent if @default_agent

      # don't action if spam
      if is_spam_new == false
        get_or_create_customer
        get_or_create_enquiry

        send_currency if @e.currency == true and @e.currency_sent == false
        send_mortgage if @e.mortgage == true and @e.mortgage_sent == false

        case
          # send private if privad and there is an agent email addr
        when @e.privad
          if @e.agent_email
            send_private
          else
            @e.err_msg = "No agent email for privad"
            @error = true
            @log.error "Enquiry #{@i}: No agent email for privad"
          end
        
          # if below the cheap limit (default or this agent) then send if not privad
        when @ischeap
          if @agent
            send_cheap
          else
            @e.err_msg = "Could not find agent"
            @error = true
            @log.error "Enquiry #{@i}: No agent for cheap"
            send_noagent_warning                #v0.93
          end
        else
          # forward for manual handling
          send_manual
        end
      else
        @e.warn_msg += "Classed as spam; no action taken. "
        @log.warn "Enquiry #{@i}: Classed as spam - client email: #{@data[:client_email]}"
        @e.ignore_it = true
        @spam_enqs += 1
      end

      @e.actioned = true if @error == false
      @e.save
      @log.info "Done record #{@i}"
    }

    #do_summary

    @log.close        #v0.94

    return @enqs.size
  end

  # test against agent limit or default
  def test_for_cheap
    if @agent_bargain_limit
      @ischeap = true if @price < @agent_bargain_limit
    else
      @ischeap = true if @price < @cheap
    end
  end

  # do one substitution
  def dosub(str, pat, data)
    ndata = data
    if not ndata
      ndata = ""
      @log.warn "Subst data was null"
    end
    tmp = str.gsub(pat, ndata)
    @log.debug "Subst #{ndata} for #{pat}. orig: #{str}, new: #{tmp}" if str.include?(pat)
    return tmp
  end

  # do all substitutions for one email field
  def make_substs(str)
    t = str
    t = dosub(t, ':client-name:', @data[:client_name])
    t = dosub(t, ':client-email:', @data[:client_email])
    t = dosub(t, ':client-phone:', @data[:client_phone])
    t = dosub(t, ':aref:', @data[:aref]) if @data[:aref]
    t = dosub(t, ':propid:', @data[:propid]) if @data[:propid]
    t = dosub(t, ':price:', @data[:price]) if @data[:price]
    t = dosub(t, ':cagent-firstname:', @data[:cagent].firstname)
    t = dosub(t, ':magent-firstname:', @data[:magent].firstname)
    t = dosub(t, ':advertiser-email:', @data[:advertiser_email]) if @e.privad
    t = dosub(t, ':advertiser-name:', @data[:advertiser_name]) if @e.privad
    t = dosub(t, ':agent-firstname:', @data[:agent].firstname) if @data[:agent]
    t = dosub(t, ':reglink:', @data[:reglink]) if @data[:reglink]
    t = dosub(t, ':enqdata:', @data[:enqdata]) if @data[:enqdata]
    t = dosub(t, ':deptreg:', @data[:region]) if @data[:region]
    t = dosub(t, ':fffp:', "1st-for-French-Property.co.uk") 
    t = dosub(t, ':hkf:', "Howard Farmer")
    t = dosub(t, ':louisa:', "Louisa Allen")
        
    t
  end

  # do all substitutions for this email
  def get_email_settings(rec)
    subject = rec.subject || "" 
    greeting = rec.greeting || ""
    preamble = rec.preamble || ""
    body = rec.body || ""
    preregions = rec.preregions || ""
    postamble = rec.postamble || ""
    signoff = rec.signoff || ""
    signature = rec.signature || ""
    
    @em_sets = {
      :subject => make_substs(subject),
      :greeting => make_substs(greeting),
      :preamble => make_substs(preamble),
      :body => make_substs(body),
      :preregions => make_substs(preregions),
      :postamble => make_substs(postamble),
      :signoff => make_substs(signoff),
      :signature => make_substs(signature)
    }
  end

  def send_currency
    get_email_settings(@currency_settings)
    if check_for_sent_email(@data[:client_email], 'currency') == false
      begin
        ClientEnquiry.deliver_currency(@data, @em_sets)
        @saved_mail << ClientEnquiry.create_currency(@data, @em_sets)
        @log.info "Enquiry #{@i}: Sending currency email to #{@data[:cagent].email1} CC #{@data[:client_email]} "
        @e.currency_sent = true
        create_agent_enquiry(@cagent, "currency")
        @currency_emails += 1
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send currency email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send currency email"
      end
    else
      @log.info "Enquiry #{@i}: Currency email not sent as previous in month for #{@data[:client_email]}"
      @e.warn_msg += "Currency email not sent as previous for client. "
    end
  end

  def send_mortgage
    if check_for_sent_email(@data[:client_email], 'mortgage') == false
      begin
        if @price < @mort_cheap
          get_email_settings(@mortgage_settings_low)
          ClientEnquiry.deliver_mortgage1(@data, @em_sets)
          @saved_mail << ClientEnquiry.create_mortgage1(@data, @em_sets)
        else
          get_email_settings(@mortgage_settings_high)
          ClientEnquiry.deliver_mortgage2(@data, @em_sets)
          @saved_mail << ClientEnquiry.create_mortgage2(@data, @em_sets)
        end
    
        create_agent_enquiry(@magent, "mortgage")
        @mortgage_emails += 1
        @log.info "Enquiry #{@i}: Sending mortgage email to #{@data[:client_email]} BCC #{@data[:magent].email1}"
        @e.mortgage_sent = true
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send mortgage email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send mortgage email"
      end
    else
      @log.info "Enquiry #{@i}: Mortgage email not sent as previous in month for #{@data[:client_email]}"
      @e.warn_msg += "Mortgage email not sent as previous for client. "
    end
  end

  def send_private
    if @e.private_client_sent == false
      begin
        get_email_settings(@private_client_settings)
        ClientEnquiry.deliver_privateClient(@data, @em_sets)
        @saved_mail << ClientEnquiry.create_privateClient(@data, @em_sets)
        msg = "Enquiry #{@i}. Sending private ad email to client #{@data[:client_email]} "
        msg += "BCC  #{@data[:defagent].email1} " if @data[:defagent]
        @log.info msg
      
        @e.private_client_sent = true
      
        create_agent_enquiry(@default_agent, "default") if @default_agent
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send private client email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send private client email"
      end
    end
    
    if @e.private_agent_sent == false
      begin
        get_email_settings(@private_advertiser_settings)
        ClientEnquiry.deliver_privateAdvertiser1(@data, @em_sets)
        @saved_mail << ClientEnquiry.create_privateAdvertiser1(@data, @em_sets)
        @log.info "Enquiry #{@i}: Sending private ad email to advertiser #{@data[:advertiser_email]}"
        @e.private_agent_sent = true
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send private agent email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send private agent email"
      end
    end

    # only send if not already sent, below check figure and not one in last 28 days.
    if @e.private_agent_earlyad_sent == false and @e.propid.to_i < @earlyad
      if check_for_private_earlyad(@data[:advertiser_email], @data[:propid]) == false
        begin
          get_email_settings(@private_advertiser_early_settings)
          ClientEnquiry.deliver_privateAdvertiser2(@data, @em_sets) 
          @saved_mail << ClientEnquiry.create_privateAdvertiser2(@data, @em_sets)
          @log.info "Enquiry #{@i}: Sending property avail email to advertiser #{@data[:advertiser_email]}"
          @e.private_agent_earlyad_sent = true
        rescue Net::SMTPFatalError => e
          @e.err_msg += "Could not send private early ad email\n"
          @error = true
          @log.error "Enquiry #{@i}: Could not send private early ad email"
        end
      else
        @log.info "Enquiry #{@i}: Private early ad email not sent as previous in month for #{@data[:advertiser_email]} and propid #{@data[:propid]}"
        @e.warn_msg += "Private early ad email not sent as previous for client. "
      end
    end
       
    @private_emails += 1
  end

  def send_cheap
    get_bargain_email_settings

    if @e.bargain_client_sent == false
      get_email_settings(@bargain_client_settings)
      begin
        ClientEnquiry.deliver_cheapClient(@data, @em_sets, @template)
        @saved_mail << ClientEnquiry.create_cheapClient(@data, @em_sets, @template)

        @log.info  "Enquiry #{@i}: Sending bargain email to client #{@data[:client_email]}"
        @e.bargain_client_sent = true
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send bargain client email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send bargain client email"
      end
    end
    
    if @e.bargain_agent_sent == false
      begin
        get_email_settings(@bargain_agent_settings)
        @saved_mail << ClientEnquiry.create_cheapAgent(@data, @em_sets)
        ClientEnquiry.deliver_cheapAgent(@data, @em_sets)
      
        @log.info "Enquiry #{@i}: Sending bargain email to agent #{@data[:agent_email]} CC #{@data[:client_email]}"
        @e.bargain_agent_sent = true
      
        create_agent_enquiry(@agent, "cheap")
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send bargain agent email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send bargain agent email"
      end
    end
    
    @bargain_emails += 1
  end

  def send_manual
    if @e.manual_sent == false
      begin
        get_email_settings(@manual_settings)
        ClientEnquiry.deliver_manual(@data, @em_sets)
        @saved_mail << ClientEnquiry.create_manual(@data, @em_sets)
        @log.info "Enquiry #{@i}: Sending manual handling email to louisa"
        @e.manual_sent = true
        @manual_emails += 1
      rescue Net::SMTPFatalError => e
        @e.err_msg += "Could not send manual email\n"
        @error = true
        @log.error "Enquiry #{@i}: Could not send manual email"
      end
    else
      @log.info  "Enquiry #{@i}: Not sending manual due to being already sent"
    end
  end

  #v0.93
  def send_noagent_warning
    ClientEnquiry.deliver_noagent(@data)
  end

  # find customer by email addr or add one
  def get_or_create_customer
    email = @e.client_email
    (tl, fs, ls) = Customer.split_name(@e.client_name)

    @cust = Customer.find_by_email(email)
    if @cust == nil
      if @e.client_phone != nil
        home = @e.client_phone
        mobile = nil
        if home[0..1] == '07'
          mobile = home
          home = nil
        end
      else
        home = nil
        mobile = nil
      end

      @cust = Customer.create(
        :email => email,
        :title => tl,
        :firstname => fs,
        :lastname => ls,
        :phone_home => home,
        :phone_mobile => mobile,
        :active => true,
        :gets_fu => true
      )
      @log.debug "Enquiry #{@i}: Created new customer"
    end
    
    @log.info "Enquiry #{@i}: Found/created customer - #{@cust.to_s}"
  end

  # find an enquiry for this customer and property or add one
  def get_or_create_enquiry
    ref = @e.aref                                    # v0.65
    
    # v0.8 checked if blank as well as nil
    if ref == nil or ref.strip == ""
      ref = "propid: " + @e.propid
    end

    @enq = Enquiry.find(:first, :conditions => ['customer_id = ? and property = ?', @cust.id(), ref ])      # v0.65
    
    if not @enq
      @enq = Enquiry.create(
        :customer_id => @cust.id(),
        :property => ref,                         # v0.65
        :region => @e.region,
        :info => @e.info_req,
        :viewing => @e.viewing_info,
        :mortgage => @e.mortgage,
        :currency => @e.currency,
        :received_at => @e.created_at
      )
          
      @e.enquiry_created = true
      @log.debug "Enquiry #{@i}: Created new enquiry"
    end
   
    @log.info "Enquiry #{@i}: Found/created enquiry for - #{@cust.to_s}, property #{ref}"
  end

  # create and agent enquiry with the enquiry type (private, cheap, default, mortgage or currency )
  def create_agent_enquiry(agent, enqtype)
    if not agent
      @log.warn "could not create agent enquiry - no agent record"
    else
      AgentEnquiry.create(
        :enquiry_id => @enq.id(),
        :agent_id => agent.id(),
        :enq_type => enqtype,
        :sent_at => @e.created_at
      )
      @log.info "Enquiry #{@i}: Creating agent enquiry - #{agent.to_s} type: #{enqtype}"
    end
  end

  # try to find a default agent for the department or region
  def get_default_agent
    rec = RegionDefault.find_by_department(@e.department) 
    rec = RegionDefault.find_by_region(@e.region) if rec == nil
    if rec != nil
      @default_agent = rec.agent
      @log.debug "Enquiry #{@i}: Found default agent #{rec.agent} for region #{@e.region} or dept #{@e.department}"
    else
      @log.warn "Enquiry #{@i}: Could not find default agent for region #{@e.region} or dept #{@e.department}"
    end
  end

  # get the agent by name
  def get_agent(name)
    ag = Agent.find_by_name1(name)
    ag = Agent.find_by_name2(name) if not ag
    ag = Agent.find_by_name3(name) if not ag
    if ag
      @log.debug "found agent #{ag.to_s} with email:#{ag.email1} from name #{name}" 
    else
      @log.warn "Could not find agent from name #{name}"
    end
    return ag
  end

  # get the currency agent with Currency in category
  def get_currency_agent
    ag = Agent.find_by_categories('Currency')
    if ag
      @log.debug "found currency agent #{ag.to_s} with email:#{ag.email1}" 
    else
      @log.error "Could not find currency agent"
    end
    return ag
  end

  # get the mortgage agent with Mortgage in category
  def get_mortgage_agent
    ag = Agent.find_by_categories('Mortgage')
    if ag
      @log.debug "found mortgage agent #{ag.to_s} with email:#{ag.email1}" 
    else
      @log.error "Could not find mortgage agent"
    end
    return ag
  end

  # save the whole email to the db as text - not used
  def save_emails
    @log.debug "There are #{@saved_mail.size} saved emails"
    @saved_mail.each do |em|
      SavedMail.create(
        :body => em.to_s
      )
    end
    @log.debug "Mails saved"
  end

  # get the region link, but handle Alsace and Lorraine specially
  # escape the url
  def get_link(region)
    base_addr = "http://www.1st-for-french-property.co.uk/property/region/"
    link = ""

    if region == 'Alsace'
      link = "http://www.1st-for-french-property.co.uk/property/main-1.php?var=state&tt=France&ss=Alsace&var1=mls"
    elsif region == "Lorraine"
      link = "http://www.1st-for-french-property.co.uk/property/main-1.php?var=state&tt=France&ss=Lorraine&var1=mls"
    else
      link = File.join(base_addr, region)
    end
    enc_link = URI.escape(link)

    @log.debug "The region link is: #{enc_link}"
    return enc_link
  end

  # setup the bulk enquiry data
  def make_enq_data
    tmp = "Enquiry:<BR>"
    tmp += "Client Name: " + @e.client_name + "<BR>" if @e.client_name
    tmp += "Client Email: " + @e.client_email + "<BR>" if @e.client_email
    tmp += "Client Phone: " + @e.client_phone + "<BR>" if @e.client_phone
    tmp += "Agent: " + @e.agent + "<BR>" if @e.agent
    tmp += "Aref: " + @e.aref + "<BR>" if @e.aref
    tmp += "Price: " + @e.price + "<BR>" if @e.price
    tmp += "Region: " + @e.region + "<BR>" if @e.region
    tmp += "Department: " + @e.department + "<BR>" if @e.department
    tmp += "Information Requested: " + @e.info_req + "<BR>" if @e.info_req
    tmp += "Viewing Info: " + @e.viewing_info + "<BR>" if @e.viewing_info
      
    tmp
  end

  # get the parms for cheap limit, mortgage limits and early ad
  def get_user_parms
    parms = UserParameter.find(1)
    @cheap = parms.bargain_limit
    @mort_cheap = parms.low_mortgage_limit
    @earlyad = parms.early_ad
    @log.info "Running with parms: Cheap: #{@cheap}, Mortgage split: #{@mort_cheap}, Early Ad Id: #{@earlyad} "
  end  

  # setup the log
  #TODO switch to rolling file
  def setup_log
    logfile = File.open("/home/englandk/rails_apps/reminders/log/auto_enquiry.log", 'a')
    
    @log = AuditLogger.new(logfile)
    @log.level = Logger::INFO
    @log.debug "Started auto response email run"
  end

  # Make first char of each work uppercase
  def capitalize_str(str)
    wrds = str.split(" ")
    wrds.each {|w|
      w.capitalize!
    }
    wrds.join(" ")
  end

  # check for sent email of the specified type in last 28 days
  def check_for_sent_email(client_email, check)
    enqs = nil

    case check
    when 'currency'
      enqs = RawEnquiry.find(:all, :conditions => ['client_email = ? and currency_sent = ? and created_at >= ?', client_email, true, @one_month_ago], :order => 'id' )
    when 'mortgage'
      enqs = RawEnquiry.find(:all, :conditions => ['client_email = ? and mortgage_sent = ? and created_at >= ?', client_email, true, @one_month_ago], :order => 'id' )
    end

    @log.debug "found #{enqs.size} matching #{check} emails for #{client_email}"

    if enqs.size > 0
      return true
    else
      return false
    end
  end

  # check for sent email for this privad property in last 28 days
  def check_for_private_earlyad(adv_email, propid)
    enqs = RawEnquiry.find(:all, :conditions => ['agent_email = ? and propid = ? and private_agent_earlyad_sent = ? and created_at >= ?', adv_email, propid, true, @one_month_ago], :order => 'id' )

    @log.debug "found #{enqs.size} matching early ad emails for #{adv_email} and propid: #{propid}"

    if enqs.size > 0
      return true
    else
      return false
    end
  end

  # check if this is spam
  def is_spam_new
    ret = false
    em = @e.client_email
    name = @e.client_name
    phon = @e.client_phone
    info = @e.info_req
    view = @e.viewing_info

    spams = SpamCheck.find(:all)
    @log.debug "Found #{spams.size} spam check records"

    spams.each {|sp|
      if sp.client_email_regex and em
        regex = Regexp.new(sp.client_email_regex)
        ret = true if em =~ regex
      end
      if sp.client_name_regex and name
        regex = Regexp.new(sp.client_name_regex)
        ret = true if name =~ regex
      end
      if sp.client_phone_regex and phon
        regex = Regexp.new(sp.client_phone_regex)
        ret = true if phon =~ regex
      end
      if sp.info_regex and info
        regex = Regexp.new(sp.info_regex)
        ret = true if info =~ regex
      end
      if sp.viewing_regex and view
        regex = Regexp.new(sp.viewing_regex)
        ret = true if view =~ regex
      end

      if sp.client_email_string and em
        ret = true if em.include?(sp.client_email_string)
      end
      if sp.client_name_string and name
        ret = true if name.include?(sp.client_name_string)
      end
      if sp.client_phone_string and phon
        ret = true if phon.include?(sp.client_phone_string)
      end
      if sp.info_string and info
        ret = true if info.include?(sp.info_string)
      end
      if sp.viewing_string and view
        ret = true if view.include?(sp.viewing_string)
      end
    }

    @log.debug "Enquiry #{@i}: Spam check returning #{ret}"
    return ret
  end

  # get the default setting for emails except bargains
  def get_default_email_settings
    @mortgage_settings_low = AgentRemindersSetting.find_by_rem_type("Mortgage Email Low")
    @mortgage_settings_high = AgentRemindersSetting.find_by_rem_type("Mortgage Email High")
    @currency_settings = AgentRemindersSetting.find_by_rem_type("Currency Email")
    @private_client_settings = AgentRemindersSetting.find_by_rem_type("Private Client")
    @private_advertiser_early_settings = AgentRemindersSetting.find_by_rem_type("Private Advertiser Early")
    @private_advertiser_settings = AgentRemindersSetting.find_by_rem_type("Private Advertiser")
    @manual_settings = AgentRemindersSetting.find_by_rem_type("Manual Handling")
  end

  # get the special settings for this agent if any otherwise get defaults
  def get_bargain_email_settings
    sets =  AgentRemindersSetting.find_by_rem_type_and_agent_id("Bargain Client Special", @agent.id)
    if sets
      @bargain_client_settings = sets
      templ = @bargain_client_settings.template
      @template = templ if templ
    else
      @bargain_client_settings = AgentRemindersSetting.find_by_rem_type("Bargain Client")
      @template = 'email'
    end

    sets = AgentRemindersSetting.find_by_rem_type_and_agent_id("Bargain Agent Special", @agent.id)
    if sets
      @bargain_agent_settings = sets
    else
      @bargain_agent_settings = AgentRemindersSetting.find_by_rem_type("Bargain Agent")
    end
  end

  def do_summary
    puts "              Name                Email                     Agent          aref      propid    price     currency  mortgage  bargain   private   manaul"
    @enqs.each {|e|
      bargain = private = mort = curr = manual = "No"

      bargain = "Yes" if e.bargain_agent_sent or e.bargain_client_sent
      private = "Yes" if e.private_client_sent or e.private_agent_sent
      mort = "Yes" if e.mortgage_sent
      curr = "Yes" if e.currency_sent
      manual = "Yes" if e.manual_sent
      
      strout = sprintf("%20.20s %30.30s %15.15s %10s %10s %10s %10s %10s %10s %10s %10s", e.client_name, e.client_email, e.agent, e.aref, e.propid, e.price, curr, mort, bargain, private, manual)
      puts strout
    }

  end

end