# used from cron to run parse
require 'rubygems'
require 'bj'
Bj.submit './script/runner ./lib/rubyrems/run_parse.rb', :tag => 'parse', :rails_env => 'production'
puts "done"
