#run the sent mail reader

load 'rubyrems/imapsentreader.rb'

ir = IMAPSentReader.new
ir.get_mail