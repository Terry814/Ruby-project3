module Admin::RawEnquiriesHelper
  def raw_enq_id_column(record)
    link_to(h(record.id()), :host => 'www.englandkit.info/reminders', :action => :do_one_raw_enq, :controller => '/rawenqs', :id => record.id())
  end
end