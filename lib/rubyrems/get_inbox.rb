# run the inbox reader
load 'rubyrems/imapinboxreader.rb'

ir = IMAPInboxReader.new
res = ir.get_mail
ir.update_last_check if res == true
