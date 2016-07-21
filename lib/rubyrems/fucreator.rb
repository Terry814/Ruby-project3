# Create the follow-up and link to enquiries
# adds the latest fu settings
# For each customer that get followup
#   set greeting with name
#   find the unsent fus where last contact was three months ago
#   for each enquiry for this customer where fu_sent is false
#   if it is in the right period
#     update enquiry with relevant fu_id
#
#     Note can be run anytime, it just relinks the agent_enquiries in the date range
#

class FuCreator
  attr_reader :fu_cnt, :enq_cnt, :oop_cnt

  def run
    @fu_cnt = 0
    @enq_cnt = 0
    @oop_cnt = 0

    rem_set = AgentRemindersSetting.find_by_rem_type('Customer Monthly')
    @month = rem_set.month
    @startdate = rem_set.from_date
    @enddate = rem_set.to_date
    puts "Month is: #{@month}. Date range is #{@startdate} - #{@enddate}"

    # for all customers who get reminders and last enquiry was in range - which is now input as actual requirded dates 26/11/10
    custs = Customer.find(:all, :conditions => "gets_fu = 1 and last_enq_date >= '#{@startdate}' and last_enq_date <= '#{@enddate}'")
    custs.each {|c|
      cust_fu_count = 0
      name = c.to_s
      greeting = sprintf(rem_set.greeting, name)

      # look for unsent reminder for month
      fu = c.customer_fus.find_by_month_and_fu_type_and_sent(@month, 'monthly', false)

      # if not found create one
      if fu == nil
        fu = c.customer_fus.create(
          :month => @month,
          :fu_type => 'monthly'
        )
        @fu_cnt += 1
      end

      fu.email_addr = c.email
      fu.subject = rem_set.subject
      fu.greeting = greeting
      fu.preamble = rem_set.preamble
      fu.preregions = rem_set.preregions
      fu.postamble = rem_set.postamble
      fu.signoff = rem_set.signoff
      fu.signature = rem_set.signature
      fu.save
      
      #link to all enquiries for this customer in right period and not yet sent
      enqs = Enquiry.find_all_by_customer_id_and_fu_sent_and_ignore_it(c.id, false, false)
      #puts "Found #{ag_enqs.size} enquiries for #{ag}" if ag_enqs.size > 0
      enqs.each {|e|
        if e.received_at != nil and e.received_at >= @startdate and e.received_at <= @enddate
          e.customer_fu_id = fu.id()
          e.save
          @enq_cnt += 1
          cust_fu_count += 1
        else
          #puts "sent_at: #{ae.sent_at}"
          @oop_cnt += 1
        end
      }
      fu.fu_count = cust_fu_count
      fu.save
    }
  end
end
