class AgentReminder < ActiveRecord::Base
  belongs_to :agent
  has_many :agent_enquiries
  has_many :agent_6m_enquiries, :class_name => 'AgentEnquiry', :foreign_key => "agent_reminder_6m_id"

  def to_label
    "#{agent}: #{created_at}"
  end

  def rem_id
    id()
  end
  
end
