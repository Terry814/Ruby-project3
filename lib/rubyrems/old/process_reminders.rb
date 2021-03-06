class ProcessReminders
  attr_reader :ar_cnt, :arl_cnt

  def run
    @ar_cnt = 0
    @arl_cnt = 0
    rem_set = AgentRemindersSettings.find(1)
    month = 'February 2010'
    subject = sprintf(rem_set.subject, month)

    # for all agents who get reminders
    agents = Agent.find_all_by_get_rem(true)
    agents.each {|ag|
      name = ag.first
      greeting = sprintf(rem_set.greeting, name)

      # look for open reminder
      ar = ag.agent_reminders.find_by_sent(false)

      # if not found create one
      if ar == nil
        ar = ag.agent_reminders.create(
          :email_addr => ag.email1,
          :subject => subject,
          :greeting => greeting,
          :preamble => rem_set.preamble,
          :postamble => rem_set.postamble,
          :signoff => rem_set.signoff
        )
        @ar_cnt += 1
      end

      #handle all enquiries for this agent not yet created
      ag_enqs = AgentEnquiry.find_all_by_agent_id_and_rem_created(ag.id, false)
      ag_enqs.each {|ae|
        enq = ae.enquiry
        cust = enq.customer
        email = enq.email
        
        ar.agent_reminder_lines.create(
          :agent_enquiry_id => ae.id,
          :customer => cust.to_s,
          :cust_email => cust.email,
          :property => enq.property,
          :enq_date => email.sent_at
        )
        @arl_cnt += 1
        ae.rem_created = true
        ae.save
      }
    }
  end
end