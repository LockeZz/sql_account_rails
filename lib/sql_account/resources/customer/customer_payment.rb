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

    has_many :knockoffs,
      class_name: 'SqlAccount::CustomerKnockoff',
      foreign_key: 'fromdockey',
      primary_key: 'dockey'


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