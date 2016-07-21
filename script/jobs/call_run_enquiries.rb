# used from cron to run enquiries
require 'rubygems'
require 'bj'
Bj.submit './script/runner ./lib/rubyrems/run_handle_raw_enquiries.rb', :tag => 'run_enquiries', :rails_env => 'production'