require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :host => 'localhost',
  :username => 'englandk_roger',
  :password => 'newh@w',
  :database => 'englandk_remindpro'
)

class Email < ActiveRecord::Base
end

def strip_colons(s)
  tmp = ""
  if s != nil
    tmp = s.gsub(/[;:\s\-\/&.()\[\]'+,?!$]/, "")
  end
  return tmp
end

ems = Email.find_all_by_source('python')

ems.each {|e|
    tmp = strip_colons(e.subject)
    if tmp =~ /.*\W.*/
      puts "#{e.id} : #{e.subject} "
    end
}

puts "done"