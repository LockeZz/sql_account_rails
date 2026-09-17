module SqlAccount
  class Journal < Record 

    self.table_name = 'journal'
    self.primary_key = 'code'

    has_many :customer_payments,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'journal',
      primary_key: 'code'

    scope :active, -> { where(isactive: true) }
    scope :inactive, -> { where(isactive: true) }

    default_scope { select(column_names - %w[attachments]) }

    # columns:
    # (1 Unknown computed col)
    # code        - Journal Code (PK, e.g. 'BANK', 'CASH', 'GENERAL')
    # description - Journal Description
    # attachments - Attachments (Binary/Blob)
    # isactive    - Active flag (boolean)

  end
end