module Admin::AgentReminderHelper
  def rem_id_column(record)
    link_to(h(record.id()), :host => 'www.englandkit.info/reminders', :action => :display_one_reminder, :controller => '/rememail', :id => record.id())
  end

end