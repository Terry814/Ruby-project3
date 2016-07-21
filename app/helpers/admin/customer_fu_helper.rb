module Admin::CustomerFuHelper
  def fu_id_column(record)
    link_to(h(record.id()), :host => 'www.englandkit.info/reminders', :action => :display_one_fu, :controller => '/fuemail', :id => record.id())
  end
end