# read the inbox - handling all mail since last checked keep any with ';' in
# subject or a subject containing any of the @@subject list or any sent to the
# @@recipient list will not store duplicates by source and source_key

require 'rubyrems/imap_handler'
require 'date'

# #TODO sort accents

class IMAPInboxReader

  @@subjects = [
    '1st for French Property - General Enquiry',
    '1st for French Property - Home Information Request',
    '1st for French Property - Leaseback Information requested',
    '1st for French Property - Buy-to-Let Information requested',
    '1st for French Property - Reversion Information requested',
    '1st for Provence Property - Information requested',
    'Questionnaire'
  ]

  @@recipients = [
    'request@1st-for-french-property.co.uk',
    'louisa@1st-for-french-property.co.uk',
    'howard.farmer@1st-for-french-property.co.uk'
  ]

  def initialize
    @dateformat = "%d-%b-%Y"    # format is 26-Apr-2010
    @parms = Parameter.find(1)
    @last_checked = @parms.last_inbox_email_load_date.strftime(@dateformat)
    @highest_inbox_uid = @parms.highest_inbox_uid
    puts "Inbox last checked on #{@last_checked} wit highest uid #{@highest_inbox_uid}"
    @n = 0
    @s = 0
  end

  def update_last_check
    d = Date.today()
    df = d.strftime(@dateformat)
    @parms.last_inbox_email_load_date = df
    @parms.highest_inbox_uid = @uid
    @parms.save
    puts "Saved inbox latest checked date as #{df} with highest uid #{@uid}"
  end

  def save_mail()
    e = Email.find_by_source_and_source_key('gmail/inbox', @uid)

    if e == nil
      e = Email.new
      e.source = 'gmail/inbox'
      e.source_key = @uid
      e.message_id =  @imh.get_msgid
      e.subject = @subj
      e.sent_at = @imh.get_sentdate
      e.from_addr = @imh.get_from
      e.to_addr = @imh.get_to
      e.cc_addr = @imh.get_cc
      e.bcc_addr = @imh.get_bcc
      e.in_reply_to = @imh.get_inreply
      e.direction = 'in'
      e.partinfo = @imh.partinfo.to_s
      e.body = @imh.get_plaintext
      e.body_type = @imh.bodytype
      e.fetch_key = @imh.fetchkey
      e.parsed = false
      e.ignore_parse = false
      e.matched = false
      e.ignore_match = false
      e.completed = false
      e.save
      # #puts "#{@n}: inserted uid #{@uid}"
      return true
    else
      # #puts "#{@n}: #{@uid} already present"
      return false
    end
  end

  def get_mail
    begin
      res = false

      @imh = ImapHandler.new

      @imh.select_inbox

      #cnt = @imh.search_by_between("01-Aug-2010", "02-Aug-2010")
      cnt = @imh.search_by_since(@last_checked)

      if cnt > 0
        @imh.uidlist.each {|uid|
          if uid > @highest_inbox_uid    #17675
            @n += 1
            @uid = uid
            begin
              @imh.fetch_info(uid)
              @subj = @imh.get_subject
              to = @imh.get_to
              if (@subj =~ /;/ or @@subjects.include?(@subj) or @@recipients.include?(to)) and
                  @subj !~ /Invoice/
                res = save_mail
                @s += 1 if res == true
              end
            rescue Exception => e
              puts "Fetch exception occurred"
      	      puts e.message
              puts "failed on #{@uid}"	
            end
          end   
        }  
      end
      
      res = true

    rescue Net::IMAP::NoResponseError => e
      puts 'No reponse Exception'
      puts e.message
      puts e.backtrace

    rescue Net::IMAP::BadResponseError => e
      puts 'Bad response Exception'
      puts e.message
      puts e.backtrace

    rescue Net::IMAP::ByeResponseError => e
      puts 'Bye response Exception'
      puts e.message
      puts e.backtrace

    rescue Exception => e
      puts "Exception occurred"
      puts e.message
      puts e.backtrace
      

    ensure
      @imh.disconnect

    end

    puts "Done #{@n}, saved #{@s}"
    return res
  end
end