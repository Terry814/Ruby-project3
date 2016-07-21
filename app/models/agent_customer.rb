class AgentCustomer < ActiveRecord::Base
  belongs_to :customer
  belongs_to :agent

  def to_s
    return "#{customer} : #{agent} : #{created_at}"
  end

  def to_label
    to_s
  end

end
