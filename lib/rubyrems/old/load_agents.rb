class OldAgent < ActiveRecord::Base
  set_table_name 'agents'
end

OldAgent.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/agent_reminders.db3'
  )

class LoadAgents 
  def LoadAgents::load_them()
    old_ags = OldAgent.find(:all, :order => 'id' )
    n = 0
    old_ags.each do |old|
      ag = Agent.new
      ag.email1 = old.email
      ag.first = old.first
      ag.last =  old.last
      ag.name1 =  old.name
      ag.phone_home = old.phone
      ag.active = true
      ag.source = 'Howard'
      ag.get_rem = true
      ag.get_6m_rem = true
      ag.save
      n += 1
    end
    return n
  end
end
