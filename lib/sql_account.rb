# frozen_string_literal: true

require "active_record"
require "firebird_adapter"
require_relative "sql_account/version"
require_relative "sql_account/configuration"
require_relative "sql_account/connection"
require_relative "sql_account/resources/record"
# require_relative "sql_account/resources/customer"
require_relative "sql_account/resources/supplier"
require_relative "sql_account/resources/stock_item"
require_relative "sql_account/resources/stock_group"
require_relative "sql_account/resources/stock_item_category"
require_relative "sql_account/resources/stock_category"
require_relative "sql_account/resources/invoice"

module SqlAccount
  class << self 

    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def establish_connection!
      Connection.establish!
    end

  end

  class Error < StandardError; end
  # Your code goes here...
end
