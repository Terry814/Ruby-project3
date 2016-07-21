# v0.1 21/1/11 added for auto-responses to emails
# v0.2 13/5/11 Amended for reply-to
# v0.3 20/5/11 Took myself out of BCC
# v0.4 21/6/11 Changes to add manual email to louisa and also to use a template from code for bargain_client
# v0.45 6/7/11 Added reply-to for the manual handling email
# v0.46 6/7/11 Added email for missing agent

class ClientEnquiry < ActionMailer::Base
  def currency(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]

    recipients data[:cagent].email1
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'
    
    cc         data[:client_email]
    bcc        'howard.farmer@gmail.com'

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  # price < 500k
  def mortgage1(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]

    recipients data[:client_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'
    
    bcc        [data[:magent].email1, data[:magent].email2, 'howard.farmer@gmail.com']

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  # price >= 500k
  def mortgage2(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]

    recipients data[:client_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'
    
    bcc        [data[:magent].email1, data[:magent].email2, 'howard.farmer@gmail.com']

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  def privateClient(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]
    
    recipients data[:client_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'

    if data[:defagent]
      bcc     [data[:defagent].email1, 'howard.farmer@gmail.com']
    else
      bcc     'howard.farmer@gmail.com'
    end

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  def privateAdvertiser1(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]
    
    recipients data[:advertiser_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to  data[:client_email]
    
    bcc         'howard.farmer@gmail.com'

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  def privateAdvertiser2(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]
    
    recipients data[:advertiser_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'
    
    bcc         'howard.farmer@gmail.com'

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  def cheapAgent(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]

    recipients data[:agent].email1
        
    from       'request@1st-for-french-property.co.uk'
    reply_to  data[:client_email]
    
    cc    data[:client_email]
    bcc   'howard.farmer@gmail.com'

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template "email"
  end

  def cheapClient(data, emsets, templ, sent_at = Time.now)
    subject    emsets[:subject]
    
    recipients data[:client_email]
    
    from       'request@1st-for-french-property.co.uk'
    reply_to   'Louisa@1st-for-french-property.co.uk'
    
    bcc        'howard.farmer@gmail.com'

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template   templ      #v0.40
  end

  # forwarding to be handled manually
  # v0.40
  def manual(data, emsets, sent_at = Time.now)
    subject    emsets[:subject]

    recipients 'Louisa@1st-for-french-property.co.uk'

    from       'request@1st-for-french-property.co.uk'
    reply_to   data[:client_email]      #v0.45

    sent_on    sent_at
    body       :emfields => emsets, :fffp => '1st-for-french-property.co.uk'
    template   "manualemail"
  end
  
  # v0.46
  def noagent(data, sent_at = Time.now)
    subject    "Auto Responses missing agent"

    recipients ["howard.farmer@gmail.com", "roger.b.crews@googlemail.com" ]

    from       'request@1st-for-french-property.co.uk'

    sent_on    sent_at
    body       "Missing agent for raw enquiry. Id: #{data[:enq_id]},  Client: #{data[:client_email]}, Property: #{data[:aref]}, Agent: #{data[:agent_name]}"
  end

end