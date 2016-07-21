# To change this template, choose Tools | Templates
# and open the template in the editor.

module RememailHelper
  # remove any duplicate lines
  def check_dup(lines, l)
    dup = false

    lines.each do |it|
      if l[:customer] == it[:customer] and
         l[:cust_email] == it[:cust_email] and
         l[:property] == it[:property]
        dup = true
      end
    end
    return dup
  end


  # a reminder object has the relevant greeting etc and an array of lines
  # where a line is a hash of info
  # only
  def make_reminder(rem)
    aes = nil
    if rem.rem_type == 'monthly'
      aes = rem.agent_enquiries.find(:all, :order => 'sent_at')
    elsif rem.rem_type == 'six-monthly'
      aes = rem.agent_6m_enquiries.find(:all, :order => 'sent_at')
    end

    ag = rem.agent
    
    subject = sprintf(rem.subject, rem.month)

    greeting = rem.greeting
    if greeting.include? '%s'
      greeting = sprintf(greeting, ag.firstname)
    end

    preamble = rem.preamble
    if preamble.include? '%s'
      preamble = sprintf(preamble, rem.month)
    end

    lines = []
    aes.each {|ae|
      if ae.ignore_it == false
        enq = ae.enquiry
        cust = enq.customer
        l = {
          :customer => cust,
          :cust_email => cust.email,
          :property => enq.property,
          :enq_date => ae.sent_at
        }
        lines << l if check_dup(lines, l) == false
      end
    }

    reminder = {
      'title' => subject,
      'email_addr' => ag.email1,
      'subject' => subject,
      'greeting' => greeting,
      'preamble' => preamble,
      'postamble' => rem.postamble,
      'signoff' => rem.signoff,
      'signature' => rem.signature,
      'lines'=> lines
    }
  end


  # make the reminder object then either display it or dummy send it
  # if no lines then render appropriate messge
  # note I use Reminder.create_agent() to view
  # to send I use Reminder.deliver_agent()
  def do_one_reminder(id, send = false )
    begin
      rem = AgentReminder.find(id)
      reminder = make_reminder(rem)
      if reminder['lines'].size > 0
        if send == false
          email = Reminder.create_agent(reminder, true)
          render(:text => "<pre>" + email.encoded + "</pre>", :layout => 'application')
        else
          email = Reminder.deliver_agent(reminder)
          render(:text => "Email sent", :layout => 'application')
        end
      else
        render(:text => "No lines for reminder: #{id}", :layout => 'application')
      end
    rescue Exception => e
      render(:text => e.message + e.backtrace.to_s)
    end
  end
end
