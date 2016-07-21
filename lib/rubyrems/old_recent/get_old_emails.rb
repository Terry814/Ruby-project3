require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'englandk_roger',
  :password => 'newh@w',
  :database => 'englandk_remindpro'
)

class Email < ActiveRecord::Base
end

def strip_quotes(s)
  tmp = ""
  if s != nil
    tmp = s.gsub(/'/, "")
    tmp = tmp.gsub(/"/, "")
  end
  return tmp
end

def strip_stop(s)
  if s != nil
    tmp = s.gsub(/\./, " ")
    return tmp
  else
    return s
  end
end

def handle_line(l, n)
  els = l.split(',')
  
  if n < 50
    puts els
  end
  
  rec_id = els[0]
  to_addr = strip_quotes(els[1])
  cc_addr = strip_quotes(els[2])
  bcc_addr = strip_quotes(els[3])
  subj = strip_quotes(els[4])
  sent_date = strip_stop(strip_quotes(els[5]))
  stored_date = strip_stop(strip_quotes(els[6]))

  sent_date = stored_date if sent_date == nil

  if sent_date != nil
      em = Email.new(
        :source => 'python',
        :source_key => rec_id,
        :direction => 'out',
        :to_addr => to_addr,
        :cc_addr => cc_addr,
        :bcc_addr => bcc_addr,
        :subject => subj,
        :sent_at => sent_date,
        :parsed => false,
        :ignore_parse => false,
        :matched => false,
        :ignore_match => false
      )
    
      em.save

      #puts "created Email for id #{rec_id}"
  end
end

n = 0
IO.foreach('/home/englandk/rails_apps/reminders/db/recent_emails.csv') do |l|
  handle_line(l, n) if n != 0
  n += 1
end

puts "done #{n}"