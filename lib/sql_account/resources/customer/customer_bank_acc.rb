module SqlAccount
  class CustomerBankAcc < Record 

    self.table_name = 'ar_customerbankacc'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

    # scopes
    scope :active,   -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: false) }

    # exclude giro blob by default
    default_scope { select(column_names - %w[giro]) }

    # columns:
    # (1 Unknown computed col)
    # autokey   - Primary Key
    # code      - FK to ar_customer.code
    # bank      - Bank Code (e.g. 'PBBEMY' = Public Bank Malaysia SWIFT code)
    # accno     - Bank Account Number
    # accname   - Account Holder Name
    # idtype    - ID Type ('B' = Business Registration, 'I' = IC, etc.)
    # id        - ID Number
    # ref       - Reference
    # giro      - Giro data (Binary/Blob)
    # isactive  - Active flag (boolean)
    # rowver    - Row Version (optimistic locking)

  end
end