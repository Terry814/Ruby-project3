require 'date'

class AgentRemindersSetting < ActiveRecord::Base
  set_table_name "agent_reminders_settings"

  belongs_to :agent

  after_save :reprocess

  # if settings changed then apply to all unsent reminders/followups of the right type
  def reprocess
    #rt = rem_type.downcase

    @rems = nil
    @fus = nil

    case rem_type
    when 'Agent Monthly'
      @rems = AgentReminder.find_all_by_rem_type_and_month_and_sent('monthly', month, false)
      set_ar_fields
    when 'Agent Six-monthly'
      @rems = AgentReminder.find_all_by_rem_type_and_month_and_sent('six-monthly', month, false)
      set_ar_fields
    when 'Customer Monthly'
      @fus = CustomerFu.find_all_by_fu_type_and_month_and_sent('monthly', month, false)
      set_fu_fields
    end
  end

  def set_ar_fields
    @rems.each {|r|
      r.subject = subject
      r.greeting = greeting
      r.preamble = preamble
      r.postamble = postamble
      r.signoff = signoff
      r.signature = signature
      r.save
    }
  end

  def set_fu_fields
    @fus.each {|f|
        f.subject = subject
        f.greeting = greeting
        f.preamble = preamble
        f.preregions = preregions
        f.postamble = postamble
        f.signoff = signoff
        f.signature = signature
        f.save
      }
  end

end
