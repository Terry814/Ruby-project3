require 'rubygems'
require 'csv'

# use models
$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '..')

require 'inc_models'

infile = '/home/englandk/rails_apps/reminders/lib/rubyrems/old_march/march_emails.csv'

# turn csv into array of hashes
def get_csv_data(infile)
  csv_data = CSV.read infile
  headers = csv_data.shift.map {|i| i.to_s }
  string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
  return  string_data.map {|row| Hash[*headers.zip(row).flatten] }
end

aoh = get_csv_data(infile)

aoh.each {|h|
  parms = {
    :source => 'python',
    :source_key => h['id'],
    :direction => 'out',
    :to_addr => h['To_Str'],
    :cc_addr => h['CC_Str'],
    :bcc_addr => h['BCC_Str'],
    :subject => h['subject'],
    :sent_at => h['sentDate'],
    :created_at => h['storedDate']
    
  }
  Email.create(parms)
}

puts "done"