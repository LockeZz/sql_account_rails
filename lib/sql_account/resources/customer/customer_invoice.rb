module SqlAccount
  # ar_iv - the AR ledger record of a customer invoice.
  #
  # ar_knockoff refers to THIS table's dockey (todockey), not to sl_iv.dockey.
  # A sales invoice (sl_iv) is linked to its ledger record by docno + customer
  # code (verified 1:1 for all sl_iv rows). ar_iv also holds invoices entered
  # directly in the AR module, which have no sl_iv row.
  #
  # Read-only.
  class CustomerInvoice < Record
    self.table_name = 'ar_iv'
    self.primary_key = 'dockey'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code',
      optional: true

    # every knockoff row that settles this invoice
    has_many :knockoffs,
      -> { where(todoctype: 'IV') },
      class_name: 'SqlAccount::CustomerKnockoff',
      foreign_key: 'todockey',
      primary_key: 'dockey'

    # only the ones made by a customer payment (fromdoctype 'PM' = ar_pm)
    has_many :payment_knockoffs,
      -> { where(todoctype: 'IV', fromdoctype: 'PM') },
      class_name: 'SqlAccount::CustomerKnockoff',
      foreign_key: 'todockey',
      primary_key: 'dockey'

    has_many :payments,
      through: :payment_knockoffs,
      source: :customer_payment

    scope :active,      -> { where(cancelled: false) }
    scope :cancelled,   -> { where(cancelled: true) }
    scope :outstanding, -> { where('docamt > paymentamt') }
    scope :for_customer, ->(code) { where(code: code) }

    # the sales invoice (sl_iv) this ledger record belongs to; nil for
    # invoices entered directly in the AR module
    def sales_invoice
      SqlAccount::SalesInvoice.find_by(docno: docno, code: code)
    end

    # amount still owed according to the ledger
    def outstanding_amount
      docamt.to_d - paymentamt.to_d
    end

    def fully_settled?
      outstanding_amount <= 0
    end

    def readonly?
      true
    end

    # columns:
    # dockey/docno/docnoex/code(customer)/journal/docdate/postdate/taxdate
    # terms/duedate/description/area/agent/project/currencycode/currencyrate
    # docamt/localdocamt  - invoice total (document / local currency)
    # paymentamt          - amount settled so far
    # fromdoctype         - source document type ('IV')
    # taxexemptno/gltransid/cancelled/status/updatecount/lastmodified
    # attachments/note/approvestate (blobs)
  end
end