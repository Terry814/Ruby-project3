module Admin::AgentEnquiryHelper
  def sent_at_column(rec)
    rec.sent_at.strftime("%d/%m/%y %H:%M:%S")    
  end
end
