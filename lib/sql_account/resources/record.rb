module SqlAccount
  class Record < ActiveRecord::Base 

    self.abstract_class = true

    def self.with_reconnect
      yield
    rescue => e
      if connection_lost(e)
        log_reconnect(e)
        SqlAccount::Connection.establish!
        yield
      else
        raise
      end
    end

    def self.connection_lost?(error)
      error.is_a?(Fb::Error)
    end

    def self.log_reconnect(error)
      message = "[SqlAccount] #{error.class}: #{error.message.to_s[0..120]} - attempting reconnect..."

      if defined?(Rails.logger) && Rails.logger
        Rails.logger.warn(message)
      else
        warn(message)
      end
    end


  end
end