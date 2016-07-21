# handle the viewing and sending of reminder emails
# uses Reminder model, and reminder views
# At present the start and end dates are hard-coded
# Actions are:
#   View or Send a single reminder_email by Agent_Reminder ID
#   View or Send all emails
#
# Single emails use do_one_reminder - to send set second parm set to true
# At present set-up to send any individual emails only to Howard and me
# Showing a single email shows the intended email address
#
# Displaying all emails will show the planned text as an on-line screen

class RememailController < ApplicationController
  include RememailHelper
  
  before_filter :login_required

  # display a single reminder in browser
  def display_one_reminder
    id = params[:id]
    do_one_reminder(id)
  end

  # display a single monthly reminder in browser
  def display_one_reminder_first
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Monthly')
    rem = AgentReminder.find(:first, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'monthly', rem_set.month, 0, false, false])
    if rem != nil
      do_one_reminder(rem.id())
    else
      render :text => "Nothing to display"
    end
  end

  # display a single six monthly reminder in browser
  def display_one_6m_reminder_first
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Six-monthly')
    rem = AgentReminder.find(:first, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'six-monthly', rem_set.month, 0, false, false])
    if rem != nil
      do_one_reminder(rem.id())
    else
      render :text => "Nothing to display"
    end
  end

  # send a single monthly reminder to howard and me
  def send_one_reminder_first
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Monthly')
    rem = AgentReminder.find(:first, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'monthly', rem_set.month, 0, false, false])
    if rem != nil
      do_one_reminder(rem.id(), true)
    else
      render :text => "Nothing to send"
    end
  end

  # send a single six monthly reminder to howard and me
  def send_one_6m_reminder_first
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Six-monthly')
    rem = AgentReminder.find(:first, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'six-monthly', rem_set.month, 0, false, false])
    if rem != nil
      do_one_reminder(rem.id(), true)
    else
      render :text => "Nothing to send"
    end
  end

  # show screen of all reminders that will be sent
  # needs ignore_it?
  def show_all_reminders
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Monthly')
    rems = AgentReminder.find(:all, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'monthly', rem_set.month, 0, false, false])
    do_all_processing(rems)
  end

  def show_all_6m_reminders
    rem_set = AgentRemindersSetting.find_by_rem_type('Agent Six-monthly')
    rems = AgentReminder.find(:all, :conditions => ['rem_type = ? and month = ? and rem_count > ? and sent = ? and ignore_it = ?', 'six-monthly', rem_set.month, 0, false, false])
    do_all_processing(rems)
  end

  def do_all_processing(rems)
    text = ''
    rems.each do |rem|
      reminder = make_reminder(rem)
      if reminder['lines'].size > 0
        email = Reminder.create_agent(reminder, true)
        text += "<pre>" + email.encoded + "</pre>"
        text += '------------------------------------------------------------------------------------------------------------------'
      end
    end
    render(:text => text, :layout => false)
  end

end