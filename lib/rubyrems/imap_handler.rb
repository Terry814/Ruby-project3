# General handler for gmail imap
# can select the mail box and do various searches
# 19/5/10
#
# v0.2 11/4/11 added in facility to copy emails to a folder and now sets seqno to the msgid
#


require 'rubygems'
require 'net/imap'

class ImapHandler
  attr_accessor :uidlist, :partinfo, :fetchkey, :bodytype, :seqno

  def initialize(debug = false)
    @debug = debug
    @imap = Net::IMAP.new('imap.gmail.com', port = 993, usessl = true)
    Net::IMAP.debug = true if @debug == true

    @imap.login('1st4frenchproperty@gmail.com', 'Louis@Fion@')
  end

  def show_folders
    puts @imap.list("/", '*')
  end

  def select_box(box)
    @imap.select(box)
    puts "#{box} folder has #{@imap.responses["EXISTS"][-1]} emails"
  end

  def select_inbox
    select_box('INBOX')
  end

  def select_sent
    select_box('[Google Mail]/Sent Mail')
  end

  def search_by_from(from)
    @uidlist = @imap.uid_search(["ALL", "FROM", from])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_to(to)
    @uidlist = @imap.uid_search(["ALL", "TO", to])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_msgid(id)
    @uidlist = @imap.uid_search(["HEADER", "Message-ID", id])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_inreply(id)
    @uidlist = @imap.uid_search(["HEADER", "In-Reply-To", id])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_text(txt)
    @uidlist = @imap.uid_search(["ALL", "TEXT", txt])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_since(date)
    @uidlist = @imap.uid_search(["ALL", "SINCE", date])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def search_by_between(date1, date2)
    @uidlist = @imap.uid_search(["ALL", "SINCE", date1, "BEFORE", date2])
    @uid = @uidlist[0]
    puts "Found #{@uidlist.size} emails"
    return @uidlist.size
  end

  def fetch_info(uid = nil)
    if uid != nil
      @uid = uid
    end

    @body = nil
    @info = @imap.uid_fetch(@uid, ["ENVELOPE", "BODYSTRUCTURE"])
    if @info.size > 0
      @envelope = @info[0].attr['ENVELOPE']
      @bds = @info[0].attr['BODYSTRUCTURE']
      @seqno = @info[0].seqno
      parse_partinfo
    end
  end

  def fetch_body(uid = nil, part = :text)
    if uid == nil
      getuid = @uid
    else
      getuid = uid
    end

    case part
    when :text
      @fetchkey = "BODY[TEXT]"
    when :all
      @fetchkey = "BODY[]"
    else
      @fetchkey = "BODY[#{part}]"
    end

    data = @imap.uid_fetch(getuid, [@fetchkey])
    @body = data[0].attr[@fetchkey]
    return @body
  end

  def split_address(addr)
    res = ""
    num = 0
    if addr != nil
      addr.each {|a|
        if a.mailbox != nil and a.host != nil
          res += ';' if num > 0
          res += a.mailbox + '@' + a.host
          num += 1
        end
      }
    end
    return res
  end

  def parse_partinfo
    @partinfo = []
    if @bds.class == Net::IMAP::BodyTypeText
      @partinfo << {:level => 0, :key =>  '1', :class => @bds.class, :type => @bds.media_type, :subtype =>  @bds.subtype}
    elsif @bds.class == Net::IMAP::BodyTypeMultipart
      level = 0
      key = ''
      recurse_partinfo(@bds.parts, level, key)
    end
  end

  def recurse_partinfo(pts, level, key)
    #puts "At level: #{level} there are #{pts.size} parts"
    pts.each_index {|i|
      p = pts[i]
      pkey = key + (i+1).to_s
      #puts "Level: #{level}, Key: #{pkey}, Part type is: #{p.class}, media_type: #{p.media_type}, subtype: #{p.subtype} "
      @partinfo << {:level => level, :key => pkey, :class => p.class, :type => p.media_type, :subtype => p.subtype}

      if p.class == Net::IMAP::BodyTypeMultipart
        level +=1
        recurse_partinfo(p.parts, level, pkey + '.')
        level -= 1
      end
    }
  end

  def get_plaintext(n = 1)
    key = ''
    found = 0
    @partinfo.each {|p|
      if p[:type] == 'TEXT' and p[:subtype] == 'PLAIN'
        found += 1
        if found == n
          key = p[:key]
          break
        end
      end
    }
    if found > 0
      @bodytype = 'plain'
      return fetch_body(nil, key)
    else
      get_htmltext(n)
    end
  end

  def get_htmltext(n = 1)
    key = ''
    found = 0
    @partinfo.each {|p|
      if p[:type] == 'TEXT' and p[:subtype] == 'HTML'
        found += 1
        if found == n
          key = p[:key]
          break
        end
      end
    }
    if found > 0
      @bodytype = 'html'
      return fetch_body(nil, key)

    else
      @bodytype = 'null'
      return nil
    end
  end

  def get_msgid
    return @envelope.message_id
  end

  def get_inreply
    return @envelope.in_reply_to
  end

  def get_sentdate
    return @envelope.date
  end

  def get_from
    addr = @envelope.from
    return split_address(addr)
  end

  def get_to
    addr = @envelope.to
    return split_address(addr)
  end

  def get_cc
    addr = @envelope.cc
    return split_address(addr)
  end

  def get_bcc
    addr = @envelope.bcc
    return split_address(addr)
  end

  def get_subject
    subj = @envelope.subject
    subj.strip! if subj != nil
    return subj
  end

  def disconnect
    @imap.disconnect if @imap != nil and @imap.disconnected? == false
  end

  # note the set must be uids
  def copy_to(set, mailbox = 'Auto')
    @imap.uid_copy(set, mailbox)
  end

end
