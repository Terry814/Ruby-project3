# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Reminders23_session',
  :secret      => 'fd09cb9018a2a7173e797071a1cc6d4ad84dcf743d37deb0d8a1a7b0dd79847ea2aa88a543c588ccfddb21d1b8d7a3f59b33376ef69055dad9bb6ce080a817f6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
