# extract various items from the stored imap emails
# 24/5/10

# use models
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'inc_models'

class IMAPEmailParser
  attr_reader :in, :out, :fu
  
  @@subjects = [
    '1st for French Property - General Enquiry',
    '1st for French Property - Home Information Request',
    '1st for French Property - Leaseback Information requested',
    '1st for French Property - Buy-to-Let Information requested',
    '1st for French Property - Reversion Information requested',
    '1st for Provence Property - Information requested',
    'Questionnaire'
  ]

  def initialize
    @in = 0
    @out = 0
    @fu = 0
  end

  def run
    ems = Email.find(:all, :conditions => ['source != "python" and parsed = 0'])
     
    puts "Found #{ems.size} emails to parse"
    ems.each {|e|
      reset_fields
      @rec = e
      @direction = e.direction
      @inreply = e.in_reply_to
      @uid = e.source_key
      @subject = e.subject
      @body = e.body
      @parsed = false

      if @direction == 'in'
        if @inreply == nil
          do_in_email
        else
          do_followup_email
        end
      elsif @direction == 'out'
        do_out_email
      else
        puts "unknown direction!"
      end
    }
  end

  def reset_fields
    @intype = nil
    @subj_cname = nil
    @subj_aref = nil
    @subj_info = nil
    @body_cname = nil
    @body_aref = nil
    @clientemail = nil
    @clientphone = nil
    @agency = nil
    @price = nil
    @inforeq = nil
    @viewreq = nil
    @mortgage = false
    @currency = false
  end

  def do_in_email
    @in += 1
    find_intype
    split_in_subject
    parse_body
    @parsed = true
    update_rec
  end

  def do_out_email
    @out += 1
    split_out_subject
    parse_body
    @parsed = true
    update_rec
  end

  def do_followup_email
    @fu += 1
  end

  def split_out_subject
    sp = @subject.split(';')
    cname = ''
    prop = ''
    info = ''

    start = sp[0]
    rest = sp[1]

    if start != nil
      start.strip!
      if start =~ /:(.*)/
        cname = $1
      else
        cname = start
      end
    end

    if rest != nil
      rest.strip!
      if rest =~ /^(.*)-(.*Viewing.*|.*Mortgage.*|.*Information.*|.*General.*)/
        prop = $1
        info = $2
      elsif rest =~ /^(.*Viewing.*|.*Mortgage.*|.*Information.*|.*General.*)/
        info = $1
      else
        prop = rest
      end
    end
    
    @subj_aref = prop.strip
    @subj_cname = cname.strip
    @subj_info = info.strip
  end

  def split_in_subject
    sp = @subject.split(';')
    cname = ''
    prop = ''
    info = ''

    start = sp[0]
    rest = sp[1]

    if start != nil
      start.strip!
      cname = start
    end

    if rest != nil
      rest.strip!
      if rest =~ /^(.*Information.*|.*General.*)/
        info = $1
      else
        prop = rest
      end
    end

    @subj_aref = prop.strip
    @subj_cname = cname.strip
    @subj_info = info.strip
  end

  def parse_body
    lines = @body.split("\r\n")
    lines.each {|l|
      @body_cname = $1 if l =~ /Please Contact: (.*)/
      @body_aref = $1 if  l =~ /Agent Ref: (.*)/
      @clientemail = $1 if l =~ /Client email: (.*)/
      @clientphone = $1 if l =~ /Tel: (.*)/
      @agency = $1 if l =~ /Agency: (.*)/
      @price = $1 if l =~ /Price: (.*)/
      @inforeq = $1 if l =~ /Info Requested: (.*)/
      @viewreq = $1 if l =~ /Viewing Requested: (.*)/
      @mortgage = true if l =~ /[M|m]ortgage/
      @currency = true if l =~ /[C|c]urrency/
    }
  end

  def find_intype
    ind = @@subjects.index(@subject)

    case ind
    when 0
      @intype = 'ffp-general'
    when 1
      @intype = 'ffp-home'
    when 2
      @intype = 'ffp-leaseback'
    when 3
      @intype = 'ffp-bytolet'
    when 4
      @intype = 'ffp-reversion'
    when 5
      @intype = 'fpp-info'
    when 6
      @intype = 'Questionaire'
    else
      @intype = "Specific-Property"
    end
  end

  def update_rec
    @rec.bus_type = @intype
    @rec.subject_cname = @subj_cname
    @rec.subject_aref = @subj_aref
    @rec.subject_info = @subj_info
    @rec.body_cname = @body_cname
    @rec.body_aref = @body_aref
    @rec.clientemail = @clientemail
    @rec.clientphone = @clientphone
    @rec.agency = @agency
    @rec.price = @price
    @rec.inforeq = @inforeq
    @rec.viewreq = @viewreq
    @rec.mortgage_info = @mortgage
    @rec.currency_info = @currency
    @rec.parsed = @parsed
    @rec.save
  end

  def show_data
    puts "uid: #{@uid} has subject client name #{@subj_cname} and is for property #{@subj_aref}"
    puts "\t has body client name #{@body_cname} and is for property #{@body_aref}"
  end
end

iep = IMAPEmailParser.new
iep.run
puts "Done: in: #{iep.in} out: #{iep.out} followup: #{iep.fu}"