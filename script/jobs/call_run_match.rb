# used from cron to run match
require 'rubygems'
require 'bj'
Bj.submit './script/runner ./lib/rubyrems/run_match.rb', :tag => 'match', :rails_env => 'production'
puts "done"
