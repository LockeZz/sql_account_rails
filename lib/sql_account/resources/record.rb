module SqlAccount
  class Record < ActiveRecord::Base 

    self.abstract_class = true

    def self.with_reconnect
      yield
    rescue => e

      raise unless connection_lost?(e)

      log_reconnect(e)
      SqlAccount::Connection.establish!
      yield
      
      # if connection_lost(e)
      #   log_reconnect(e)
      #   SqlAccount::Connection.establish!
      #   yield
      # else
      #   raise
      # end
    end

    # ActiveRecord wraps driver errors (ActiveRecord::StatementInvalid with the
    # original Fb::Error as #cause), so the whole cause chain must be checked.
    #
    # Firebird SQL mistakes (bad syntax, unknown table/column) carry
    # "SQL error code = -NNN"; retrying those cannot help, so they are excluded.
    #
    # INTERIM: the exact message of a genuinely dropped connection has not been
    # captured yet. Once it has, narrow this to that message.
    def self.connection_lost?(error)
      # error.is_a?(Fb::Error)

      while error
        if error.is_a?(Fb::Error)
          return !error.message.to_s.match?(/sql error code/i)
        end
        error = error.cause 
      end
      false 
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