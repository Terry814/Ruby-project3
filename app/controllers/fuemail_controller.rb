class FuemailController < ApplicationController
  include FuemailHelper
  
  before_filter :login_required

  # display a single followup in browser
  def display_one_fu
    id = params[:id]
    do_one_fu(id)
  end

  def display_one_fu_first
    fu_set = AgentRemindersSetting.find_by_rem_type('Customer Monthly')
    fu = CustomerFu.find(:first, :conditions => ['fu_count > ? and sent = ? and month = ? and ignore_it = ?', 0, false, fu_set.month, false ])
    if fu != nil
      do_one_fu(fu.id())
    else
      render :text => "nothing to show"
    end
  end

  # send a single reminder to howard and me
  def send_one_fu_first
    fu_set = AgentRemindersSetting.find_by_rem_type('Customer Monthly')
    fu = CustomerFu.find(:first, :conditions => ['fu_count > ? and sent = ? and month = ? and ignore_it = ?', 0, false, fu_set.month, false ])
    if fu != nil
      do_one_fu(fu.id(), true)
    else
      render :text => "nothing to send"
    end
  end

  # show screen of all reminders that will be sent
  def show_all_fus
    fu_set = AgentRemindersSetting.find_by_rem_type('Customer Monthly')
    fus = CustomerFu.find(:all, :conditions => ['fu_count > ? and sent = ? and month = ? and ignore_it = ?', 0, false, fu_set.month, false ], :limit => 10, :order => 'id')
    text = ''
    fus.each do |fu|
      fup = make_fu(fu)
      email = Followup.create_customer(fup, true)
      text += "<pre>" + email.encoded + "</pre>"
      text += '------------------------------------------------------------------------------------------------------------------'
    end
    render(:text => text, :layout => false)
  end

end