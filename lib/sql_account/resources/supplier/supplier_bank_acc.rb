module SqlAccount
  class SupplierBankAcc < Record
    self.table_name = 'ap_supplierbankacc'
    self.primary_key = 'autokey'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code'

    scope :active,   -> { where(isactive: 'T') }
    scope :inactive, -> { where(isactive: 'F') }

    # exclude binary columns
    default_scope { select(column_names - %w[giro]) }

    validates :code,   presence: true
    validates :bank,   presence: true
    validates :accno,  presence: true

    # columns:
    # autokey  - Primary Key
    # code     - Supplier Code (FK to ap_supplier.code)
    # bank     - Bank Code
    # accno    - Bank Account Number
    # accname  - Account Holder Name
    # idtype   - ID Type
    # id       - ID Number
    # ref      - Reference
    # giro     - GIRO data (Binary/Blob)
    # isactive - T/F
    # rowver   - Row version (system use)
  end
end
