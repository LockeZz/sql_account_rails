module SqlAccount
  class CashBookEntry < Record 

    self.table_name = 'gl_cb'
    self.primary_key = 'dockey'
    self.ignored_columns = %w[attachments]

    SOURCE_TYPES = {
      'SP' => 'Supplier Payment',
      'PM' => 'Cusomter Payment',
      'CF' => 'Customer Refund',
      'SF' => 'Supplier Refund'
    }.freeze 

    has_many :lines,
      -> { order(:seq) },
      class_name:  'SqlAccount::CashBookEntryLine',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    # paymentmethod holds the bank/cash GL account code
    belongs_to :payment_account,
      class_name:  'SqlAccount::GlAccount',
      foreign_key: 'paymentmethod',
      primary_key: 'code',
      optional:    true

    scope :payment_vouchers,  -> { where(doctype: 'PV') }
    scope :official_receipts, -> { where(doctype: 'OR') }
    scope :not_cancelled,     -> { where(cancelled: false) }
    scope :cancelled_only,    -> { where(cancelled: true) }
    scope :cash_book_only,    -> { where(fromdoctype: nil) }
    scope :from_payments,     -> { where.not(fromdoctype: nil) }
    scope :dated_between,     ->(from, to) { where(docdate: from..to) }

        def readonly?
      true
    end

    def payment_voucher?
      doctype.to_s.strip == 'PV'
    end

    def official_receipt?
      doctype.to_s.strip == 'OR'
    end

    def cancelled?
      cancelled == true
    end

    def cash_book_only?
      fromdoctype.to_s.strip.empty?
    end

    # e.g. "Supplier Payment", or nil when entered directly in Cash Book
    def source_type
      SOURCE_TYPES[fromdoctype.to_s.strip]
    end

    # The ar_pm record this OR mirrors (only for fromdoctype 'PM')
    def customer_payment
      return unless fromdoctype.to_s.strip == 'PM'
      SqlAccount::CustomerPayment.find_by(docno: docno)
    end

    def lines_total
      lines.sum(:amount)
    end

  end
end