
class SqliteEmail < ActiveRecord::Base
  set_table_name 'emails'
end

SqliteEmail.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/agent_reminders.db3'
) 

class ReadEmails
  def ReadEmails::get_emails_dummy(from, to)
    recs = SqliteEmail.find(:all, :conditions => ['sentDate >= ? and sentDate <= ?', from, to ])
    recs.each do |rec|
      OldEmail.create(
        :to_addr => rec.To_Str,
        :cc_addr => rec.CC_Str,
        :bcc_addr => rec.BCC_Str,
        :subject => rec.subject,
        :body => nil,
        :sent_at => rec.sentDate,
        :created_at => rec.storedDate,
        :parsed => false,
        :ignore => false,
        :completed => false,
        :incoming => false,
        :sourceId => "sqlite3#{rec.id()}"
      )
    end
    return recs.size
  end
  
end
