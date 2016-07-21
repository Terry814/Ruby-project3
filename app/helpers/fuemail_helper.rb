module FuemailHelper
  # To change this template, choose Tools | Templates
  # and open the template in the editor.

  # remove any duplicate lines
  def check_dup(lines, l)
    dup = false

    lines.each do |it|
      if l[:region] == it[:region]
        dup = true
      end
    end
    return dup
  end


  def get_link(region)
    base_addr = "http://www.1st-for-french-property.co.uk/property/region/"
    link = ""

    if region == 'Alsace'
      link = "http://www.1st-for-french-property.co.uk/property/main-1.php?var=state&tt=France&ss=Alsace&var1=mls"
    elsif region == "Lorraine"
      link = "http://www.1st-for-french-property.co.uk/property/main-1.php?var=state&tt=France&ss=Lorraine&var1=mls"
    else
      link = File.join(base_addr, region, "/")
    end
    return link
  end


  # a reminder object has the relevant greeting etc and an array of lines
  # where a line is a hash of info
  # only
  def make_fu(fu)
    enqs = fu.enquiries.find(:all, :order => 'received_at')

    subject = sprintf(fu.subject, fu.month)

    greeting = fu.greeting
    if greeting.include? '%s'
      cust = fu.customer
      name = cust.to_s
      greeting = sprintf(greeting, name)
    end

    preamble = fu.preamble
    if preamble.include? '%d'
      n = fu.fu_count
      preamble = sprintf(preamble, n)
    end

    lines = []
    enqs.each {|e|
      if e.ignore_it == false and e.region != nil
        l = {
          :region => e.region,
          :link => get_link(e.region)
        }
        lines << l if check_dup(lines, l) == false
      end
    }

    fup = {
      'title' => subject,
      'email_addr' => fu.email_addr,
      'subject' => subject,
      'greeting' => greeting,
      'preamble' => preamble,
      'preregions' => fu.preregions,
      'postamble' => fu.postamble,
      'signoff' => fu.signoff,
      'signature' => fu.signature,
      'lines'=> lines,
      'rmv_txt' => 'If you want to be removed from our enquiry list please email Louisa at louisa@1st-for-french-property.co.uk quoting customer ref : ',
      'cust_id' => fu.customer_id
    }
  end


  # make the reminder object then either display it or dummy send it
  # if no lines then render appropriate messge
  # note I use Reminder.create_agent() to view
  # to send I use Reminder.deliver_agent()
  def do_one_fu(id, send = false )
    begin
      fu = CustomerFu.find(id)
      fup = make_fu(fu)
      #if fup['lines'].size > 0
        if send == false
          email = Followup.create_customer(fup, true)
          render(:text => "<pre>" + email.encoded + "</pre>", :layout => 'application')
        else
          email = Followup.deliver_customer(fup)
          render(:text => "Email sent", :layout => 'application')
        end
      #else
      #  render(:text => "No lines for reminder: #{id}", :layout => 'application')
      #end
    rescue Exception => e
      render(:text => e.message + e.backtrace.to_s + fup.to_s)
    end
  end
end