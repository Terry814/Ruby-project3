# read the sent emails handles any since last checked keeps any with ';' in
# subject will not store duplicates by source and source_key

# #1/12/10 found bug with save_email checking the inbox not sent for already
# there!

# NOTE IF USING MUST CHANGE CODE THAT READS GMAIL TO SINCE AND NOT HARD CODED
# DATES!

#
# v0.2 11/4/11
#   checks for auto responses and moves them to Auto folder, does not use them
#   also now excluded any with Invoice in the subject
#


# #TODO sort accents

require 'rubyrems/imap_handler'

class IMAPSentReader

  def initialize
    @dateformat = "%d-%b-%Y"    # format is 26-Apr-2010
    @parms = Parameter.find(1)
    @last_checked = @parms.last_sent_email_load_date.strftime(@dateformat)
    @highest_sent_uid = @parms.highest_sent_uid
    puts "Sent mail last checked on #{@last_checked} highest uid #{@highest_sent_uid}"
    @n = 0
    @s = 0
    @auto = 0
    @autotxt = /AR1st/
  end

  def update_last_check
    d = Date.today()
    df = d.strftime(@dateformat)
    @parms.last_sent_email_load_date = df
    @parms.highest_sent_uid = @uid
    @parms.save
    puts "Saved sent latest checked date as #{df} with highest sent uid of #{@uid}"
  end

  def save_mail()
    e = Email.find_by_source_and_source_key('gmail/sent', @uid)

    if e == nil
      e = Email.new
      e.source = 'gmail/sent'
      e.source_key = @uid
      e.message_id =  @imh.get_msgid
      e.subject = @subj
      e.sent_at = @imh.get_sentdate
      e.from_addr = @imh.get_from
      e.to_addr = @imh.get_to
      e.cc_addr = @imh.get_cc
      e.bcc_addr = @imh.get_bcc
      e.in_reply_to = @imh.get_inreply
      e.direction = 'out'
      e.partinfo = @imh.partinfo.to_s
      e.body = @body
      e.body_type = @imh.bodytype
      e.fetch_key = @imh.fetchkey
      e.parsed = false
      e.ignore_parse = false
      e.matched = false
      e.ignore_match = false
      e.completed = false
      e.save
      # #puts "#{@n}: inserted uid #{@uid}"

    else
      # #puts "#{@n}: #{@uid} already present"
    end
  end

  def get_mail
    begin
      @imh = ImapHandler.new

      @imh.select_sent

      #cnt = @imh.search_by_between("01-Aug-2010", "02-Aug-2010")  # <++++ change this!
      cnt = @imh.search_by_since(@last_checked)

      if cnt > 0
        @imh.uidlist.each {|uid|
          if uid > @highest_sent_uid
            @n += 1
            @uid = uid
            @imh.fetch_info(uid)
            @subj = @imh.get_subject
            @body = @imh.get_plaintext
            handle_sentmail
          end
        }
        puts "Done #{@n}, saved #{@s}, #{@auto} copied to Auto"
        update_last_check
      end

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
  end

  def handle_sentmail
    if @body =~ @autotxt
      @imh.copy_to(@uid)
      @auto += 1
    else
      if @subj =~ /;/ and @subj !~ /Invoice/
        @s += 1
        save_mail
      end
    end
  end
end