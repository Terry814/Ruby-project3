class Admin::AgentController < ApplicationController
  before_filter :login_required
  
  active_scaffold :agent do |config|
    config.list.columns = [:id, :email1, :email2, :email3, :firstname, :lastname, :name1,
      :name2, :name3, :categories, :bargain_limit, :phone_home, :phone_mobile, :agent_enquiries, :agent_reminders, :agent_reminders_settings]
    config.list.sorting = [:firstname => :asc]
    config.update.columns = [:email1, :email2, :email3, :firstname, :lastname, :name1,
      :name2, :name3, :categories, :bargain_limit, :phone_home, :phone_mobile, :get_rem, :get_6m_rem, :active,:agent_reminders_settings ]
    config.create.columns = [:email1, :email2, :firstname, :lastname, :name1,
      :name2, :name3, :categories, :bargain_limit, :phone_home, :phone_mobile, :get_rem, :get_6m_rem, :active, :agent_reminders_settings]
  end
end