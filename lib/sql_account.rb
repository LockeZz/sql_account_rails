# frozen_string_literal: true

require "active_record"
require "firebird_adapter"
require_relative "sql_account/version"
require_relative "sql_account/configuration"
require_relative "sql_account/connection"

require_relative "sql_account/resources/record"

# require_relative "sql_account/resources/customer"
require_relative "sql_account/resources/supplier"

# Supplier
require_relative 'sql_account/resources/supplier'
require_relative 'sql_account/resources/supplier_branch'
require_relative 'sql_account/resources/supplier_bank_acc'
require_relative 'sql_account/resources/supplier_cr_ctrl'
require_relative 'sql_account/resources/supplier_tariff'

# Stock
require_relative 'sql_account/resources/stock_item'
require_relative 'sql_account/resources/stock_item_uom'
require_relative 'sql_account/resources/stock_item_barcode'
require_relative 'sql_account/resources/stock_item_bom'
require_relative 'sql_account/resources/stock_item_alt'
require_relative 'sql_account/resources/stock_item_category'
require_relative 'sql_account/resources/stock_item_company'
require_relative 'sql_account/resources/stock_item_price'
require_relative 'sql_account/resources/stock_item_tpl'
require_relative 'sql_account/resources/stock_item_tpldtl'
require_relative 'sql_account/resources/stock_item_matrix'
require_relative 'sql_account/resources/stock_item_batch'
require_relative 'sql_account/resources/stock_item_ob'
require_relative 'sql_account/resources/stock_transaction'
require_relative 'sql_account/resources/stock_transaction_wma'
require_relative "sql_account/resources/stock_category"
require_relative 'sql_account/resources/stock_group'
require_relative 'sql_account/resources/stock_batch'
require_relative 'sql_account/resources/stock_assembly'
require_relative 'sql_account/resources/stock_assembly_line'
require_relative 'sql_account/resources/stock_adjustment'
require_relative 'sql_account/resources/stock_adjustment_line'

# Purchase
require_relative 'sql_account/resources/purchase_request'
require_relative 'sql_account/resources/purchase_request_line'
require_relative 'sql_account/resources/purchase_document'
require_relative 'sql_account/resources/purchase_document_line'
require_relative "sql_account/resources/purchase_invoice"
require_relative "sql_account/resources/purchase_invoice_line"

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
