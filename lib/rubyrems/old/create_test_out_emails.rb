require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'roger',
  :password => 'rbc0171',
  :database => 'reminders_development'
)

class LiveEmail < ActiveRecord::Base
end

LiveEmail.connection.execute("Truncate table live_emails")

def insert_rec(data)
  e = LiveEmail.new
  e.uid = data[:uid]
  e.subject = data[:subject]
  e.to = data[:to]
  e.cc = data[:cc]
  e.bcc = data[:bcc]
  e.direction = 'out'
  e.envelope = data[:env]
  e.body = data[:body]
  e.internal_date = data[:date]
  e.save
  puts "inserted uid: #{data[:uid]}"
end


data_list = [
  {
    :uid => 1,
    :subject => 'Brian Hatch ; 501425',
    :to => 'agent1@somenet.com',
    :cc => 'suewoodpeckers@somemail.com',
    :bcc => '',
    :env => '',
    :body => "---------- Forwarded message ----------
From: 1st for French Property <request@1st-for-french-property.co.uk>
Date: Wed, Mar 3, 2010 at 8:50 PM
Subject: Brian Hatch ; 501425
To: request@1st-for-french-property.co.uk



Client Details:
Please Contact: Brian Hatch
Client email: suewoodpeckers@somemail.com
Tel: 01794342400

Agency: LindseyB
Agent Ref: 501425

Info Requested: would it be possible to view this property on the 20th march
or the 21st thank

An enquiry from 1st for French Property website",
    :date => "2010-03-04 08:52:12"
  },
  {
    :uid => 2,
    :subject => 'John Lee; aps1661',
    :to => '',
    :cc => 'john.d.lee@somenet.com',
    :bcc => 'agent1@somenet.com, agent2@somenet.com, agent3@somenet.com',
    :env => '',
    :body => "---------- Forwarded message ----------
From: 1st for French Property <request@1st-for-french-property.co.uk>
Date: Wed, Mar 3, 2010 at 8:07 PM
Subject: John Lee; aps1661
To: request@1st-for-french-property.co.uk



Client Details:
Please Contact: John Lee
Client email: john.d.lee@somenet.com
Tel: 0044 7540 221847

Agency: AntonyB
Agent Ref: aps1661

Info Requested: Any more photgraphs and details of the town , shops , market
etc. I am looking for a town proeprty

An enquiry from 1st for French Property website",
    :date => "2010-03-04 08:53:33"
  },
  {
    :uid => 3,
    :subject => 'Brian Barnes ; 1123456',
    :to => 'agent1@somenet.com',
    :cc => 'bbarnes@somemail.com',
    :bcc => '',
    :env => '',
    :body => "---------- Forwarded message ----------
From: 1st for French Property <request@1st-for-french-property.co.uk>
Date: Wed, Mar 3, 2010 at 8:50 PM
Subject: Brian Barnes ; 1123456
To: request@1st-for-french-property.co.uk



Client Details:
Please Contact: Brian Barnes
Client email: bbarnes@somenet.com
Tel: 01794342400

Agency: LindseyB
Agent Ref: 1123456

Info Requested: would it be possible to view this property on the 20th march
or the 21st thank

An enquiry from 1st for French Property website",
    :date => "2010-03-04 08:52:12"
  },
  {
    :uid => 4,
    :subject => 'John Knox; apd1661',
    :to => '',
    :cc => 'john.knox@somenet.com',
    :bcc => 'agent1@somenet.com, agent4@somenet.com, agent3@somenet.com',
    :env => '',
    :body => "---------- Forwarded message ----------
From: 1st for French Property <request@1st-for-french-property.co.uk>
Date: Wed, Mar 3, 2010 at 8:07 PM
Subject: John Knox; apd1661
To: request@1st-for-french-property.co.uk



Client Details:
Please Contact: John Knox
Client email: john.knox@somenet.com
Tel: 0044 7540 221847

Agency: AntonyB
Agent Ref: apd1661

Info Requested: Any more photgraphs and details of the town , shops , market
etc. I am looking for a town proeprty

An enquiry from 1st for French Property website",
    :date => "2010-03-04 08:53:33"
  }
]

data_list.each {|l|
  insert_rec(l)
}

puts "done"

