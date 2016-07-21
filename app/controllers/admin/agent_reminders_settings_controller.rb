class Admin::AgentRemindersSettingsController < ApplicationController
  before_filter :login_required

  active_scaffold :agent_reminders_settings do | config |
    config.list.columns = [:rem_type, :agent, :subject, :greeting, :preamble, :body, :preregions, :rpt_body, :postamble, :signoff, :signature, :template, :month,  :from_date, :to_date, :auto_date]
    config.update.columns = [:rem_type, :agent, :subject, :greeting, :preamble, :body, :preregions, :rpt_body, :postamble, :signoff, :signature, :template, :month,  :from_date, :to_date, :auto_date]
    config.create.columns = [:rem_type, :agent, :subject, :greeting, :preamble, :body, :preregions,  :rpt_body, :postamble, :signoff, :signature, :template, :month,  :from_date, :to_date, :auto_date]
    config.columns[:greeting].form_ui = :textarea
    config.columns[:greeting].options = {:cols => 80, :rows => 2}
    config.columns[:preamble].form_ui = :textarea
    config.columns[:preamble].options = {:cols => 80, :rows => 8}
    config.columns[:preregions].form_ui = :textarea
    config.columns[:preregions].options = {:cols => 80, :rows => 8}
    config.columns[:postamble].form_ui = :textarea
    config.columns[:postamble].options = {:cols => 80, :rows => 8}
    config.columns[:signature].form_ui = :textarea
    config.columns[:signature].options = {:cols => 80, :rows => 2}
    config.columns[:signoff].form_ui = :textarea
    config.columns[:signoff].options = {:cols => 80, :rows => 2}
    config.columns[:subject].form_ui = :textarea
    config.columns[:subject].options = {:cols => 80, :rows => 2}
    config.columns[:body].form_ui = :textarea
    config.columns[:body].options = {:cols => 80, :rows => 3}
    config.columns[:rpt_body].form_ui = :textarea
    config.columns[:rpt_body].options = {:cols => 80, :rows => 2}
 

  end

  def before_update_save(record)
    if record.auto_date == true
      td = Date.today
      first_of_this = Date.new(td.year, td.month, 1)
      first_of_prev = first_of_this << 1
      last_of_prev = first_of_this - 1
      first_of_7ago = first_of_this << 7
      last_of_2ago = (first_of_this << 1) - 1
      first_of_4ago = first_of_this << 4
      last_of_4ago = (first_of_this << 3) - 1

      case record.rem_type
      when 'Agent Monthly'
        record.from_date = first_of_prev
        record.to_date = last_of_prev
        record.month = first_of_prev.strftime("%b %Y")
      when 'Agent Six-monthly'
        record.from_date = first_of_7ago
        record.to_date = last_of_2ago
        record.month = first_of_7ago.strftime("%b %Y") + ' - ' + last_of_2ago.strftime("%b %Y")
      when 'Customer Monthly'
        record.from_date = first_of_4ago
        record.to_date = last_of_4ago
        record.month = first_of_4ago.strftime("%b %Y")
      end
    end
  end

end