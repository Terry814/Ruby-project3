# Read emails from the web server and put them into LiveEmails

require 'net/pop'

mails = []

class Inmail < ActionMailer::Base
  @@subjects = [
    '1st for French Property - Information requested',
    'Home Information Request',
    '1st for French Property - More mortgage information requested',
    'Questionnaire',
    '1st for French Property - Leaseback Information requested',
    '1st for French Property - Buy-to-Let Information requested'
  ]

  def Inmail.subjects
    return @@subjects
  end
  
  def receive(em)
    rec = LiveEmail.find_by_message_id(em.message_id)
    new = false
    
    if not rec
      ind = @@subjects.index(em.subject.chomp.strip)  
      
      type = 'default'
      
      case ind
      when 0
        type = 'first-info'
      when 1
        type = 'home-info'
      when 2
        type = 'mortgage-info'
      when 3
        type = 'questionaire'
      when 4
        type = 'leaseback'
      when 5
        type = 'buy-to-let'
      end
      
      LiveEmail.create(
        :message_id => em.message_id,
        :delivery_date => em.date,
        :header => em.header,
        :body => em.body,
        :enq_type => type,
        :parsed => false
      )
      new = true
    end
    return new
  end
 
end

Net::POP3.start('1st-for-french-property.co.uk', 110,
  'webvivre', '69wealden27') do |pop|
  if pop.mails.empty?
    puts 'No mail.'
  else
    i = 0
    pop.each_mail do |m|
      subject = m.header.split(/\r\n/).grep(/Subject:/)
      tmp = subject[0].gsub(/Subject:/, '').strip
      mails << m.pop if Inmail.subjects.include?(tmp)
      i += 1
    end
    puts "There were #{pop.mails.size} emails in total."
  end
end

puts "There are #{mails.size} relevant emails"

added = 0
mails.each do |n|
  rc = Inmail.receive(n)
  added += 1 if rc
end

puts "Added #{added} emails"
