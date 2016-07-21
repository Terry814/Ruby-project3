$:.unshift File.dirname(__FILE__)

require 'inc_models'

class IMAPEmailParser
  attr_reader :in, :out, :fu
  
  def initialize
    @in = 0
    @out = 0
    @fu = 0
  end

  def run
    ems = Email.find(:all,
      :conditions => ['source = "python" and parsed = 0'])
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

      do_out_email
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

  def do_out_email
    @out += 1
    split_out_subject
    tmp = @rec.cc_addr.gsub("'", '')
    @clientemail = tmp
    @parsed = true
    update_rec
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
      if rest =~ /^(.*)-(.*Viewing.*|.*viewing.*|.*Mortgage.*|.*mortgage.*|.*Information.*|.*information.*|.*General.*|.*general.*)/
        prop = $1
        info = $2
      elsif rest =~ /^(.*Viewing.*|.*viewing.*|.*Mortgage.*|.*mortgage.*|.*Information.*|.*information.*|.*General.*|.*general.*)/
        info = $1
      else
        prop = rest
      end
    end
    
    @subj_aref = prop.strip
    @subj_cname = cname.strip
    @subj_info = info.strip
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