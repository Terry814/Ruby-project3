class Followup < ActionMailer::Base
  def customer(fup, realaddr = false)
    subject    fup['subject']
    body        :fup => fup
    if realaddr == true
      recipients  fup['email_addr']
    else
      recipients  ['fiona@virtual-presence.co.uk', 'louisa@1st-for-french-property.co.uk']
    end
    from        'monthlyreports@1st-for-french-property.co.uk'
    sent_on     Time.now
  end

end
