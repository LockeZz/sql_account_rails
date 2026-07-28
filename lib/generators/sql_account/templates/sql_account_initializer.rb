SqlAccount.configure do |config|
  config.host     = ENV['SQL_ACCOUNT_HOST']
  config.port     = ENV.fetch('SQL_ACCOUNT_PORT', 3050)
  config.database = ENV['SQL_ACCOUNT_DATABASE']
  config.username  = ENV['SQL_ACCOUNT_USERNAME']
  config.password  = ENV['SQL_ACCOUNT_PASSWORD']
  config.encoding  = 'UTF-8'

  config.pool = 5
  config.checkout_timeout = 5
  config.idle_timeout = 300
end

SqlAccount.establish_connection!

if defined?(Rails::Console)
  puts "[SqlAccount] Connected to Firebird: #{ENV['SQL_ACCOUNT_HOST']}"
  puts "[SqlAccount] If connection drops, run: SqlAccount::Connection.reconnect!"
end