module SqlAccount
  class CustomerKnockoff < Record 

    self.table_name = "ar_knockoff"

    belongs_to :customer_payment,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'fromdockey',
      primary_key: 'dockey',
      optional: true

    belongs_to :sales_invoice,
      class_name: 'SqlAccount::SalesInvoice',
      foreign_key: 'todockey',
      primary_key: 'dockey',
      optional: true

    scope :from_payment,  -> { where(fromdoctype: 'PM') }
    scope :from_cn,       -> { where(fromdoctype: 'CN') } 
    scope :to_invoice,    -> { where(todoctype: 'IV') }
    scope :to_cn,         -> { where(todoctype: 'CN') }
    scope :with_gainloss, -> { where('gainloss <> 0') }

    # Doc type constants
    FROM_PAYMENT     = 'PM'.freeze
    FROM_CREDIT_NOTE = 'CN'.freeze
    TO_INVOICE       = 'IV'.freeze
    TO_CREDIT_NOTE   = 'CN'.freeze

    def from_payment?
      fromdoctype == FROM_PAYMENT
    end

    def to_invoice?
      todoctype == TO_INVOICE
    end

    def has_forex_gainloss?
      gainloss.to_d != 0
    end

    # columns:
    # dockey          - Sequential key (NOT a surrogate PK in the traditional sense)
    # fromdoctype     - Source document type: 'PM' = Payment, 'CN' = Credit Note
    # fromdockey      - Source document key (ar_pm.dockey or ar_cn.dockey)
    # todoctype       - Target document type: 'IV' = Invoice, 'CN' = Credit Note
    # todockey        - Target document key (sl_iv.dockey)
    # koamt           - Knockoff Amount (document currency)
    # actuallocalkoamt- Actual Local Currency Knockoff Amount
    # localkoamt      - Local Currency Knockoff Amount
    # kotaxdate       - Knockoff Tax Date (for SST/GST reporting)
    # gainloss        - Forex Gain/Loss on settlement
    # gainlosspostdate- Gain/Loss Post Date

  end
end