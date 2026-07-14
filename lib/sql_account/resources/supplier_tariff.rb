module SqlAccount
  class SupplierTariff < Record
    self.table_name = 'ap_suppliertariff'
    self.primary_key = 'autokey'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code'

    # validations
    validates :code,   presence: true
    validates :tariff, presence: true

    # columns:
    # autokey - Primary Key
    # code    - Supplier Code (FK to ap_supplier.code)
    # tariff  - Tariff Code
    # tax     - Tax Code
    # rowver  - Row version (system use)
  end
end
