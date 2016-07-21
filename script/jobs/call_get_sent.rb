# used from cron to run get_sent
require 'rubygems'
require 'bj'
Bj.submit './script/runner -e production ./lib/rubyrems/get_sent.rb', :tag => 'sent', :rails_env => 'production'
puts "done"