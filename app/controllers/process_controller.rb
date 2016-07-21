class ProcessController < ApplicationController
  layout nil
  before_filter :login_required
  
  def get_process_info
    @inbox = Bj.table.job.find_last_by_tag('inbox')
    @sent = Bj.table.job.find_last_by_tag('sent')
    @parse = Bj.table.job.find_last_by_tag('parse')
    @match = Bj.table.job.find_last_by_tag('match')
    @createrem = Bj.table.job.find_last_by_tag('create_rem')
    @create6mrem = Bj.table.job.find_last_by_tag('create_6m_rem')
    @sendrem = Bj.table.job.find_last_by_tag('send_rem')
    @send6mrem = Bj.table.job.find_last_by_tag('send_6m_rem')
    @createfus = Bj.table.job.find_last_by_tag('create_fus')
    @sendfus = Bj.table.job.find_last_by_tag('send_fus')
    @runenquiries = Bj.table.job.find_last_by_tag('run_enquiries')
    @rundummy = Bj.table.job.find_last_by_tag('run_dummy')
  end

  def index
    get_process_info
    render :layout => 'application'
  end

  def update_process_info
    get_process_info
  end

  def get_inbox
    Bj.submit './script/runner ./lib/rubyrems/get_inbox.rb', :tag => 'inbox'
    render :text => "Read inbox job submitted"
  end

  def get_sent
    Bj.submit './script/runner ./lib/rubyrems/get_sent.rb', :tag => 'sent'
    render :text => "Read sent mail job submitted"
  end

  def run_parse
   Bj.submit './script/runner ./lib/rubyrems/run_parse.rb', :tag => 'parse'
   render :text => "Parse job submitted"
  end

  def run_match
   Bj.submit './script/runner ./lib/rubyrems/run_match.rb', :tag => 'match'
   render :text => "Match job submitted"
  end

  def run_reminders
   Bj.submit './script/runner ./lib/rubyrems/run_reminders.rb', :tag => 'create_rem'
   render :text => "Create reminders job submitted"
  end

  def send_reminders
   Bj.submit './script/runner ./lib/rubyrems/send_all_reminders.rb', :tag => 'send_rem'
   render :text => "Send reminders job submitted"
  end

  def run_6m_reminders
   Bj.submit './script/runner ./lib/rubyrems/run_6mreminders.rb', :tag => 'create_6m_rem'
   render :text => "Create 6m reminders job submitted"
  end

  def send_6m_reminders
   Bj.submit './script/runner ./lib/rubyrems/send_all_6m_reminders.rb', :tag => 'send_6m_rem'
   render :text => "Send 6m reminders job submitted"
  end

  def run_fus
   Bj.submit './script/runner ./lib/rubyrems/run_fus.rb', :tag => 'create_fus'
   render :text => "Create Follow-ups job submitted"
  end

  def send_fus
   Bj.submit './script/runner ./lib/rubyrems/send_all_fus.rb', :tag => 'send_fus'
   render :text => "Send Follow-ups job submitted"
  end

  def run_enquiries
   Bj.submit './script/runner ./lib/rubyrems/run_handle_raw_enquiries.rb', :tag => 'run_enquiries'
   render :text => "Run enquiry job submitted"
  end

  def run_dummy
   Bj.submit './script/runner ./lib/rubyrems/run_dummy.rb', :tag => 'run_dummy'
   render :text => "Run dummy job submitted"
  end

end
