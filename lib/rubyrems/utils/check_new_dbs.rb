#!/opt/bin/ruby

puts "started" 

require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :database => 'englandk_reminddev',
  :username => 'englandk_roger',
  :password => 'newh@w'
)

class BjJobArchive < ActiveRecord::Base
  set_table_name 'bj_job_archive'
end

jobs = BjJobArchive.find(:all)
jobs.each {|j|
  puts j.pid
}


puts "done"