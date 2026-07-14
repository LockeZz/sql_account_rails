module SqlAccount
  class SupplierCrCtrl < Record
    self.table_name = 'ap_suppliercrctrl'
    self.primary_key = 'dtlkey'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code'

    # validations
    validates :code,    presence: true
    validates :doctype, presence: true

    # columns:
    # dtlkey      - Primary Key
    # code        - Supplier Code (FK to ap_supplier.code)
    # doctype     - Document Type this credit control applies to
    # controltype - Control Type (integer)
    # suspendmsg  - Message shown when credit limit exceeded
  end
end
