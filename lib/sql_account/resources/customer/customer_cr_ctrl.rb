module SqlAccount
  class CustomerCrCtrl < Record
    self.table_name = 'ar_customercrctrl'
    self.primary_key = 'dtlkey'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

    # Control type constants (controltype integer)
    # 0 = No control
    # 1 = Warning
    # 2 = Block/Suspend

    scope :blocking, -> { where(controltype: 2) }
    scope :warning,  -> { where(controltype: 1) }

    def blocking?
      controltype == 2
    end

    def warning?
      controltype == 1
    end

    # columns:
    # dtlkey      - Primary Key
    # code        - FK to ar_customer.code
    # doctype     - Document Type this control applies to
    # controltype - Control Type: 0 = None, 1 = Warning, 2 = Block/Suspend
    # suspendmsg  - Message shown when document is suspended/blocked
    #
    # NOTE: table is empty in TESTING.FDB
  end
end