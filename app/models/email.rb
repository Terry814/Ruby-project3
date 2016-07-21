class Email < ActiveRecord::Base
  has_one :inenquiry, :foreign_key => 'in_email_id', :class_name => "Enquiry"
  has_one :outenquiry, :foreign_key => 'out_email_id', :class_name => "Enquiry"
  
  attr_reader :cust_tl, :cust_fs, :cust_ls
  
  @name_parsed = false

  def to_s
    "#{source} : #{source_key}"
  end

  def cust_first_name
    parse_cust_name if not @name_parsed
    return @cust_fs
  end
  
  def cust_last_name
    parse_cust_name if not @name_parsed
    return @cust_ls
  end
  
  def cust_title
    parse_cust_name if not @name_parsed
    return @cust_tl
  end
  
  #parse the name into title, first and last  
  def parse_cust_name
    @name_parsed = true

    @cust_tl = ''
    @cust_fs = ''
    @cust_ls = ''


    temp = subject_cname
    temp = body_cname if temp == nil
    temp = '' if temp == nil

    temp.gsub!(/^.*:/, '')  # remove RE: FW: etc

    res = Customer.split_name(temp)

    @cust_tl = res[0]
    @cust_fs = res[1]
    @cust_ls = res[2]
  end
   
   def property
    prop = subject_aref
    if prop == nil
      prop = body_aref if body_aref != nil
    end
    return prop
  end

  def info
    info = inforeq
    if info == nil
      info = subject_info if subject_info != nil
    end
    return info
  end
end

 