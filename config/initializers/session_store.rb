# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rubytime_session',
  :secret      => 'c7a113f513539dd484fd73a657ed90eabc9d9eac6adea58829ba6b51736adec267a83d176b70832c8329ffac32eb96ad97a61e5076d1f73cf7222e570e56a6c9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
