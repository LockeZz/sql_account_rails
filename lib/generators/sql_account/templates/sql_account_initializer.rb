SqlAccount.configure do |config|
  config.host     = ENV['SQL_ACCOUNT_HOST']
  config.port     = ENV.fetch('SQL_ACCOUNT_PORT', 3050)
  config.database = ENV['SQL_ACCOUNT_DATABASE']
  config.username  = ENV['SQL_ACCOUNT_USERNAME']
  config.password  = ENV['SQL_ACCOUNT_PASSWORD']
  config.encoding  = 'UTF-8'
end

SqlAccount.establish_connection!