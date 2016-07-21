class Admin::RegionDefaultsController < ApplicationController
  before_filter :login_required

  active_scaffold :RegionDefaults do |config|
    config.list.columns = [:region, :department, :agent]
    config.list.sorting = [:region, :department]
    config.update.columns = [:region, :department, :agent]
    config.create.columns = [:region, :department, :agent]
  end
end
