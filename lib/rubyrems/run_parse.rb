# run the parser

require 'rubyrems/imapemailparser'

iep = IMAPEmailParser.new
iep.run

puts "In: #{iep.in}, Out: #{iep.out}, follow-up: #{iep.fu}"
