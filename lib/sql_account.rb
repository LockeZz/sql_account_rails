# frozen_string_literal: true

require "firebird_adapter"
require "active_record"
require 'active_support'
require 'active_support/concern'
require_relative "sql_account/version"
require_relative "sql_account/configuration"
require_relative "sql_account/connection"

require_relative 'sql_account/concerns/purchase_document'
require_relative 'sql_account/concerns/purchase_document_line'


require_relative "sql_account/resources/record"
require_relative "sql_account/resources/project/project"
# require_relative "sql_account/resources/customer"

# Fixed Asset
require_relative "sql_account/resources/fixed_asset/fa_di_project"
require_relative "sql_account/resources/fixed_asset/fa_item_project"

# Supplier
require_relative 'sql_account/resources/supplier/supplier'
require_relative 'sql_account/resources/supplier/supplier_branch'
require_relative 'sql_account/resources/supplier/supplier_bank_acc'
require_relative 'sql_account/resources/supplier/supplier_cr_ctrl'
require_relative 'sql_account/resources/supplier/supplier_tariff'

# Stock
require_relative 'sql_account/resources/stock/stock_item'
require_relative 'sql_account/resources/stock/stock_item_uom'
require_relative 'sql_account/resources/stock/stock_item_barcode'
require_relative 'sql_account/resources/stock/stock_item_bom'
require_relative 'sql_account/resources/stock/stock_item_alt'
require_relative 'sql_account/resources/stock/stock_item_category'
require_relative 'sql_account/resources/stock/stock_item_company'
require_relative 'sql_account/resources/stock/stock_item_price'
require_relative 'sql_account/resources/stock/stock_item_tpl'
require_relative 'sql_account/resources/stock/stock_item_tpldtl'
require_relative 'sql_account/resources/stock/stock_item_matrix'
require_relative 'sql_account/resources/stock/stock_item_batch'
require_relative 'sql_account/resources/stock/stock_item_ob'
require_relative 'sql_account/resources/stock/stock_transaction'
require_relative 'sql_account/resources/stock/stock_transaction_wma'
require_relative "sql_account/resources/stock/stock_category"
require_relative 'sql_account/resources/stock/stock_group'
require_relative 'sql_account/resources/stock/stock_batch'
require_relative 'sql_account/resources/stock/stock_assembly'
require_relative 'sql_account/resources/stock/stock_assembly_line'
require_relative 'sql_account/resources/stock/stock_adjustment'
require_relative 'sql_account/resources/stock/stock_adjustment_line'

# Purchase
require_relative 'sql_account/resources/purchasing/purchase_request'
require_relative 'sql_account/resources/purchasing/purchase_request_line'
require_relative 'sql_account/resources/purchasing/purchase_order'
require_relative 'sql_account/resources/purchasing/purchase_order_line'
require_relative "sql_account/resources/purchasing/purchase_invoice"
require_relative "sql_account/resources/purchasing/purchase_invoice_line"
require_relative "sql_account/resources/purchasing/purchase_goods_receive"
require_relative "sql_account/resources/purchasing/purchase_goods_receive_line"
require_relative 'sql_account/resources/purchasing/purchase_return'
require_relative 'sql_account/resources/purchasing/purchase_return_line'
require_relative 'sql_account/resources/purchasing/cash_purchase'
require_relative 'sql_account/resources/purchasing/cash_purchase_line'
require_relative 'sql_account/resources/purchasing/purchase_debit_note'
require_relative 'sql_account/resources/purchasing/purchase_debit_note_line'
require_relative 'sql_account/resources/purchasing/purchase_credit_note'
require_relative 'sql_account/resources/purchasing/purchase_credit_note_line'
require_relative 'sql_account/resources/purchasing/purchase_extra_goods'
require_relative 'sql_account/resources/purchasing/purchase_extra_goods_line'


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
