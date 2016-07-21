class Admin::CustomerFuController < ApplicationController
  before_filter :login_required
  
  active_scaffold :customer_fu do |config|
    config.list.columns = [:fu_id, :customer, :fu_type, :month, :fu_count, :subject, :greeting, :preamble, :preregions, :postamble,
      :signoff, :sent, :ignore_it, :enquiries ]
    config.show.columns = [:fu_id, :customer, :fu_type, :month, :fu_count, :subject, :greeting, :preamble, :preregions, :postamble,
      :signoff, :sent, :ignore_it, :enquiries ]
  end

  def conditions_for_collection
    ['fu_count > 0 and sent = 0']
  end
end