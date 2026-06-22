module SqlAccount
  module Connection

    def self.establish!
      ActiveRecord::Base.establish_connection(SqlAccount.configuration.to_h)
    end

  end
end