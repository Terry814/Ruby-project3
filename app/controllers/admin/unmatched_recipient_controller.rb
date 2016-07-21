class Admin::UnmatchedRecipientController < ApplicationController
  before_filter :login_required
  
  active_scaffold :unmatched_recipient do |config|
    config.list.columns = [:id, :enquiry, :recipient_str, :ignore_it]
    config.list.sorting = [:recipient_str => :asc]
    config.list.per_page = 25
    config.update.columns = [:id, :recipient_str, :ignore_it]
  end
  
  def conditions_for_collection
    ['unmatched_recipients.ignore_it = 0']
  end
end