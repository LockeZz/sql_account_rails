module SqlAccount
  class CustomerPayment < Record

    self.table_name = "ar_pm"
    self.primary_key = "dockey"

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code',
      optional: true

    belongs_to :project,
      class_name: 'SqlAccount::Project',
      foreign_key: 'project',
      primary_key: 'code',
      optional: true

    belongs_to :journal,
      class_name: 'SqlAccount::Journal',
      foreign_key: 'journal',
      primary_key: 'code',
      optional: true
    
    belongs_to :received_bank,
      class_name: 'SqlAccount::GlAccount',
      foreign_key: 'paymentmethod',
      primary_key: 'code',
      optional: true

    has_many :knockoffs,
      class_name: 'SqlAccount::CustomerKnockoff',
      foreign_key: 'fromdockey',
      primary_key: 'dockey'
      

    validates :docno,         presence: true
    validates :code,          presence: true
    validates :docdate,       presence: true
    validates :postdate,      presence: true
    validates :paymentmethod, presence: true
    validates :docamt,        presence: true, numericality: { greater_than: 0 }

    scope :active,         -> { where(cancelled: false) }
    scope :cancelled,      -> { where(cancelled: true) }
    scope :bounced,        -> { where.not(bounceddate: nil) }
    scope :non_refundable, -> { where(nonrefundable: true) }
    scope :for_customer,   ->(code)     { where(code: code) }
    scope :by_date,        ->(date)     { where(docdate: date) }
    scope :between,        ->(from, to) { where(docdate: from..to) }
    scope :for_project,    ->(proj)     { where(project: proj) }
    scope :unallocated,    -> { where('unappliedamt > 0') }
    scope :fully_applied,  -> { where(unappliedamt: 0) }

    default_scope { select(column_names - %w[attachments note approvestate]) }

    def cancelled?
      cancelled == true
    end

    def cancel!
      update!(cancelled: true)
    end

    def bounced?
      bounceddate.present?
    end

    def fully_applied?
      unappliedamt.to_d == 0
    end

    def unapplied_amount
      unappliedamt.to_d
    end

    def multi_currency?
      currencycode.present? && currencycode != '----'
    end
    
    # columns:
    # (2 Unknown computed cols)
    # dockey            - Primary Key
    # docno             - Document No (e.g. 'OR-00001')
    # code              - Customer Account Code (FK to ar_customer.code)
    # docdate           - Document Date
    # postdate          - Post Date
    # taxdate           - Tax Date
    # description       - Payment Description
    # area              - Area
    # agent             - Agent
    # paymentmethod     - Bank/Cash GL Account (FK to gl_acc.code, e.g. '310-001')
    # chequenumber      - Cheque Number
    # journal           - Journal Type (e.g. 'BANK')
    # project           - Project (FK to project.code)
    # paymentproject    - Payment Project (separate from invoice project)
    # currencycode      - Currency Code ('----' = local)
    # currencyrate      - Exchange Rate
    # bankacc           - Bank Account (integer FK — bank account table)
    # bankcharge        - Bank Charge Amount
    # bankchargeaccount - Bank Charge GL Account (FK to gl_acc.code)
    # docamt            - Payment Amount (document currency)
    # localdocamt       - Payment Amount (local currency)
    # unappliedamt      - Unallocated/unapplied amount remaining
    # docref1/2         - Document References
    # fromdoctype       - Source document type (if payment originated from another doc)
    # fromdockey        - Source document key
    # gltransid         - GL Transaction ID
    # cancelled         - Cancelled flag (boolean)
    # status            - Status (integer)
    # nonrefundable     - Non-refundable flag (boolean)
    # bounceddate       - Bounced cheque date (nil = not bounced)
    # updatecount       - Update Count
    # attachments       - Attachments (Binary/Blob)
    # note              - Notes (Binary/Blob)
    # approvestate      - Approval State (Binary/Blob)
    # lastmodified      - Last Modified (Unix timestamp)
    # banktransfertype  - Bank Transfer Type (online banking)
    # bankrefno         - Bank Reference Number
    # bankstatus        - Bank Status (integer, online banking)
    # bankstatusdesc    - Bank Status Description
  end
end