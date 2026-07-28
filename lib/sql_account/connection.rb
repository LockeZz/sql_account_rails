module SqlAccount
  module Connection

    def self.establish!
      # ActiveRecord::Base.establish_connection(SqlAccount.configuration.to_h)
      SqlAccount::Record.establish_connection(SqlAccount.configuration.to_h)
    end

    def self.reconnect!
      SqlAccount::Record.connection.reconnect!
    rescue StandardError
      establish!
    end

    def self.alive?
      SqlAccount::Record.connection.execute("SELECT 1 FROM RDS$DATABASE")
      true
    rescue StandardError
      false
    end

  end
end