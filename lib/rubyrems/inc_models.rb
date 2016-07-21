# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__), '../../app/models')

require 'rubygems'
require 'active_record'

require 'email'
require 'customer'
require 'enquiry'
require 'agent_enquiry'
require 'agent'
require 'agent_reminder'
require 'agent_reminders_setting'
require 'customer_reminder_setting'
require 'customer_fu'
require 'parameter'
require 'unmatched_recipient'

ActiveRecord::Base.establish_connection(
      :adapter => 'mysql',
      :host => '127.0.0.1',
      :username => 'englandk_roger',
      :password => 'newh@w',
      :database => 'englandk_remindpro'
    )
    
