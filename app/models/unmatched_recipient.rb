class UnmatchedRecipient < ActiveRecord::Base
  belongs_to :enquiry
  
  after_save :reprocess

  @@reprocess = true

  def UnmatchedRecipient::setReprocess(val)
    @@reprocess = val
  end

  def to_s
    "#{enquiry}: #{recipient_str}"
  end
  
  def to_label
    to_s
  end
  
  # if the unmatched address is changed then try to match it
  def reprocess
    if @@reprocess == true
      ret = Agent.find_one_agent(recipient_str)
      result = false
    
      if ret.class == Agent
        agt_enq = AgentEnquiry.find_by_enquiry_id_and_agent_id(enquiry.id, ret.id)
        if not agt_enq
          AgentEnquiry.create(
            :enquiry_id => enquiry.id,
            :agent_id => ret.id,
            :sent_at => enquiry.received_at
          )
        end
        destroy
        result = true
      end
      return result
    end
  end
  
  # try to match all unmatched records. Called when agent(s) are changed
  def UnmatchedRecipient.reprocess_all
    if @@reprocess == true
      recs = self.find(:all, :conditions => ['ignore_it = 0'])
      n = 0
      recs.each {|r|
        rc = r.reprocess
        n += 1 if rc
      }
      return n
    end
  end
 
end