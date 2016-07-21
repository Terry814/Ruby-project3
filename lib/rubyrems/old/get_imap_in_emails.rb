# Read the gmail inbox and store the mail
# 20/5/10

$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'date'
require 'imap_handler'
require 'inc_models'

class Parameter < ActiveRecord::Base
end

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
    'louisa@1st-for-french-property.co.uk'

  ]

  def initialize
    @dateformat = "%d-%b-%Y"    # format is 26-Apr-2010
    @parms = Parameter.find(1)
    @last_checked = @parms.last_inbox_email_load_date.strftime(@dateformat)
    puts "Inbox last checked on #{@last_checked}"
    @n = 0
    @s = 0
  end

  def update_last_check
    d = Date.today()
    df = d.strftime(@dateformat)
    @parms.last_inbox_email_load_date = df
    @parms.save
    puts "Saved inbox latest checked date as #{df}"
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
      e.save
      puts "#{@n}: inserted uid #{@uid}"
      
    else
      puts "#{@n}: #{@uid} already present"
    end
  end

  def get_mail
    begin
      @imh = ImapHandler.new
      
      @imh.select_inbox

      cnt = @imh.search_by_since(@last_checked)

      if cnt > 0
        @imh.uidlist.each {|uid|
          @n += 1
          @uid = uid
          @imh.fetch_info(uid)
          @subj = @imh.get_subject
          to = @imh.get_to
          if @subj =~ /;/ or @@subjects.include?(@subj) or @@recipients.include?(to)
            @s += 1
            save_mail
          end
        }
        puts "Done #{@n}, with body #{@s}"
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
end

ir = IMAPInboxReader.new
ir.get_mail

puts "done"