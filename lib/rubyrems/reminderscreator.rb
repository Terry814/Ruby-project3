# Create the reminders and link to agent_enquiries
# adds the latest reminder settings
# Takes the month and dates from reminders settings
# For each agent that get reminders
#   set greeting with firstname
#   find the unsent reminder for this month or create one
#   for each agent_enquiry for this agent where rem_sent is false
#   if it is in the right period
#     update agent_enquiry with relevant reminder_id
#
#     Note can be run anytime, it just relinks the agent_enquiries in the date range
#     amended 20/10/10 to pick up the latest settings as well when rerun

class RemindersCreator
  attr_reader :new_ar_cnt, :exist_ar_cnt, :ae_cnt, :oop_cnt

  def initialize()
    @rem_set = AgentRemindersSetting.find_by_rem_type('Agent Monthly')
    @month = @rem_set.month
    @startdate = @rem_set.from_date
    @enddate = @rem_set.to_date
    puts "Month is: #{@month}. Date range is #{@startdate} - #{@enddate}"
  end

  def run
    @new_ar_cnt = 0
    @exist_ar_cnt = 0
    @ae_cnt = 0
    @oop_cnt = 0
        
    # for all agents who get reminders
    agents = Agent.find_all_by_get_rem(true)
    agents.each {|ag|
      ag_rem_count = 0
      name = ag.firstname
      greeting = sprintf(@rem_set.greeting, name)

      # look for unsent reminder for month
      ar = ag.agent_reminders.find_by_month_and_rem_type_and_sent(@month, 'monthly', false)

      # if not found create one
      if ar == nil
        ar = ag.agent_reminders.create(
          :month => @month,
          :rem_type => 'monthly'
        )
        @new_ar_cnt += 1
      else
        @exist_ar_cnt += 1
      end

      ar.email_addr = ag.email1
      ar.subject = @rem_set.subject
      ar.greeting = greeting
      ar.preamble = @rem_set.preamble
      ar.postamble = @rem_set.postamble
      ar.signoff = @rem_set.signoff
      ar.signature = @rem_set.signature
      ar.save

      #link to all enquiries for this agent in right period and not yet sent
      ag_enqs = AgentEnquiry.find_all_by_agent_id_and_rem_sent_and_ignore_it(ag.id, false, false)
      #puts "Found #{ag_enqs.size} enquiries for #{ag}" if ag_enqs.size > 0
      ag_enqs.each {|ae|
        if ae.sent_at >= @startdate and ae.sent_at <= @enddate
          ae.agent_reminder_id = ar.id()
          ae.save
          @ae_cnt += 1
          ag_rem_count += 1
        else
          #puts "sent_at: #{ae.sent_at}"
          @oop_cnt += 1
        end
      }
      ar.rem_count = ag_rem_count
      ar.save
    }
  end
end


