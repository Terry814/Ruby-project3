class Agent < ActiveRecord::Base
  has_many :agent_enquiries
  has_many :agent_reminders
  has_many :agent_reminders_settings
    
  after_save :reprocess_unmatched

  @@reprocess = true

  def Agent::setReprocess(val)
    @@reprocess = val
  end

  def to_s
    return "#{firstname} #{lastname}"
  end

  def to_label
    to_s
  end

  def reprocess_unmatched
    n = UnmatchedRecipient.reprocess_all if @@reprocess == true
  end
  
  # find the agents in a given string using name and email returns an array of
  # agent object for ones found and an array of the bits of the string it cannot
  # find
  def Agent.find_agents(s)
    agents = []
    not_found = []
    
    return agents, not_found if s.strip == '' or s == nil
    
    # downcase and remove any quotes
    s.downcase!
    s.gsub!("'", "")
    
    # split the string on the ; and remove any blank elements
    strs = s.split(';') 
    strs.delete_if {|x| x.strip == ''}
    
    strs.each do |s|
      ret = Agent.find_one_agent(s)
      if ret.class == Agent
        agents << ret
      else
        not_found << s unless s.strip == 'seb'
      end
    end
    return agents, not_found
  end
  
  def Agent.find_one_agent(s)
    name = s.strip
    email = ''
      
    # does it match 'xxxx (xxx@xx)' format
    if name =~ /(.*)\((\S*@\S*)\)/
      name = $1
      email = $2
      
      # does it match 'xxx@xxx'
    elsif name =~ /(\S*@\S*)/
      name = ''
      email = $1        
    end
      
    name.strip! if name and name.length > 0
    email.strip! if email and email.length > 0
      
    # search by email
    rec = Agent.find(:first,
      :conditions => ["trim(lower(email1)) = ? or trim(lower(email2)) = ? or trim(lower(email3)) = ?",
        email, email, email]) if email and email.length > 0 
    if not rec
      rec = Agent.find(:first, 
        :conditions => ["trim(lower(name1)) = ? or trim(lower(name2)) = ? or trim(lower(name3)) = ?",
          name, name, name]) if name and name.length > 0
    end
    return rec
   end
end
