# This file is automatically copied into RAILS_ROOT/initializers

config_file = "#{RAILS_ROOT}/config/smtp_gmail.yml"
raise "Sorry, you must have #{config_file}" unless File.exists?(config_file)

config_options = YAML.load_file(config_file)
ActionMailer::Base.smtp_settings = {
  :authentication => :plain
}.merge(config_options) # Configuration options override default options