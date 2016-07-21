class AgentEnquiry < ActiveRecord::Base
  belongs_to :enquiry
  belongs_to :agent
  belongs_to :agent_reminder
  belongs_to :agent_6m_reminder, :class_name => 'AgentReminder', :foreign_key => "agent_reminder_6m_id"
  
  def to_s
    "#{enquiry} : #{agent}"
  end
  
  def to_label
    to_s
  end
end