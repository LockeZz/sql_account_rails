module SqlAccount
  module Connection

    def self.establish!
      # ActiveRecord::Base.establish_connection(SqlAccount.configuration.to_h)
      SqlAccount::Record.establish_connection(SqlAccount.configuration.to_h)
    end

  end
end