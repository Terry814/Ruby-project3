require 'bj'

class Bj
  # not needed but might be useful
  module ClassMethods
    def showConfig
      Bj.config.each {|k,v|
        puts "Key: #{k}; value: #{v}"
      }

      puts "Bj Rails Env: #{rails_env}"
      puts "Bj Rails root: #{rails_root}"
      puts "Host: #{hostname}"
      puts "Bj Logname: #{Runner.log}"
    end
  end
  send :extend, ClassMethods

  class Runner
    module ClassMethods
      # override the command used to run the jobs
      attribute("rbclog") {"/home/englandk/rails_apps/reminders/log/rbc_bj.log"}

      def command
        cmd = "#{ Bj.ruby } " + %W[
          #{ Bj.script }
          run
          --forever
          --redirect=#{ rbclog }
          --ppid=#{ Process.pid }
          --rails_env=#{ Bj.rails_env }
          --rails_root=#{ Bj.rails_root }
          --log=#{rbclog}
        ].map{|word| word.inspect}.join(" ")

        puts "Using command: #{cmd}"

        cmd
      end
    end
    send :extend, ClassMethods
  end

end