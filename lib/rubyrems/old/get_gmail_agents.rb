# Load agents from the gmail downloaded contacts csv
# 25/5/10

require 'rubygems'
require 'csv'

# use models
thisdir =  File.dirname(__FILE__)
$:.unshift thisdir

require 'inc_models'

Agent.setReprocess(false)

infile = File.join(thisdir, 'contacts.csv')

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
    :first => h['First Name'],
    :last => h['Last Name'],
    :company => h['Company'],
    :categories => h['Categories'],
    :priority => h['Priority'],
    :email1 => h['E-mail Address'],
    :phone_bus => h['Business Phone'],
    :phone_bus2 => h['Business Phone 2'],
    :phone_mobile => h['Mobile Phone'],
    :fax => h['Business Fax'],
    :notes => h['Notes'],
    :job_title => h['Job Title'],
    :address_home => h['Home Address'],
    :active => true,
    :source => 'gmail_contacts',
    :get_rem => true,
    :get_6m_rem => true,
    :created_at => Time.now,
    :updated_at => Time.now
  }
  Agent.create(parms)
}

puts "done"