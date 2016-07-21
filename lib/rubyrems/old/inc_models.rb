# just include the rails models
# 23/5/10

$:.unshift File.join(File.dirname(__FILE__), "../../app/models")

require 'active_record'
require 'agent'
require 'agent_enquiry'
require 'agent_reminder'
require 'agent_reminder_line'
require 'agent_reminders_setting'
require 'customer'
require 'enquiry'
require 'unmatched_recipient'
require 'email'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
    :host => 'localhost',
    :username => 'englandk_roger',
    :password => 'newh@w',
    :database => 'englandk_reminders'
)