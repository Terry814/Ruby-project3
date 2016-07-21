module Admin::EnquiryHelper
  def received_at_column(rec)
    rec.received_at.strftime("%d/%m/%y %H:%M:%S")    
  end
end
