class Reminder < ActionMailer::Base

  # realaddr parm control who it is sent to - false -> howard and me
  def agent(reminder, realaddr = false)
    subject    reminder['subject']
    body        :reminder => reminder
    if realaddr == true
      recipients  reminder['email_addr']
    else
      recipients  ['fiona@virtual-presence.co.uk', 'louisa@1st-for-french-property.co.uk']
    end
    from        'monthlyreports@1st-for-french-property.co.uk'
    sent_on     Time.now
  end
  
end