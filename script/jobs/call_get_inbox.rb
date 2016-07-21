# used from cron to run get_inbox
require 'rubygems'
require 'bj'
Bj.submit './script/runner -e production ./lib/rubyrems/get_inbox.rb', :tag => 'inbox', :rails_env => 'production'