class HomeController < ApplicationController
  before_filter :login_required
  
  def index
    
  end

  def showtime
    
  end

  def say_when
    render :text => "<p>The time is <b>" + DateTime.now.to_s + "</b></p>"
  end

  def empty_unmatched
    @n = UnmatchedRecipient.delete_all
  end

  def remove_customer

  end

  def show_test_emails
    ems = SavedMail.find(:all)
    n = 1
    str = "#{ems.size} emails that would be sent<BR>--------------------------------------------<BR>"
    ems.each  do |em|
      str << "<BR>Email #{n}<BR>"
      str << em.body
      str << "<BR>----------------------------------------------------<BR>"
      n +=1 
    end
    render :text => str
  end

  def clear_test_emails
    ActiveRecord::Base.connection.execute('Truncate table saved_mails')
    render :text => "Saved email cleared"
  end

  def tag_cust
    @cust_id = params[:id]
    @cust_email = Customer.find(@cust_id)

    @agents = Agent.find(:all, :order => 'lastname')
    dummyag = Agent.new
    dummyag.id = -1
    dummyag.email1 = 'None selected'

    @agents.insert(0, dummyag)
  end

  def do_tag
    @cust_id = params[:cust_id]
    @agent_id = params[:agent_id]

    cust = Customer.find(@cust_id)
    agt  = Agent.find(@agent_id)

    existing = AgentCustomer.find_by_customer_id_and_agent_id(@cust_id, @agent_id)

    if cust == nil
      flash.now[:error] = "Customer not valid"
      render 'tag_cust'
    elsif agt == nil
      flash.now[:error] = "Agent not valid"
      render 'tag_cust'
    elsif existing != nil
      flash.now[:error] = "Tag already exists"
      render 'home/index'
    else
      AgentCustomer.create(
        :customer_id => @cust_id,
        :agent_id => @agent_id,
        :active => true,
        :source => params[:source]
      )
      flash.now[:notice] = "Customer tagged - #{cust.email} for agent #{agt.email1}"
      render 'home/index'
    end
  end

end