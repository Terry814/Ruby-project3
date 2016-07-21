class Admin::CustomerController < ApplicationController
  before_filter :login_required
  
  active_scaffold :customer do |config|
    config.list.columns = [:id, :title, :firstname, :lastname, :email, :alt_email,
      :phone_home, :phone_mobile, :enquiries]
    config.list.sorting = [:lastname => :asc]
    config.list.per_page = 25
    config.update.columns = [:title, :firstname, :lastname, :email, :alt_email, :phone_home, :phone_mobile, :gets_fu, :active ]
  end
end