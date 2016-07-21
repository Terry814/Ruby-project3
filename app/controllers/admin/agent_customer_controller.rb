class Admin::AgentCustomerController < ApplicationController
  before_filter :login_required

  active_scaffold :agent_customer do |config|
    config.list.columns = [:id, :customer, :agent, :source, :active, :created_at]
    config.update.columns = [:id, :customer, :agent, :source,  :active, :created_at ]
    config.create.columns = [:id, :customer, :agent, :source, :active, :created_at]
  end
end
