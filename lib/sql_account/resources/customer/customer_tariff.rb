module SqlAccount
  class CustomerTariff < Record
    self.table_name = 'ar_customertariff'
    self.primary_key = 'autokey'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

    # columns:
    # autokey  - Primary Key
    # code     - FK to ar_customer.code
    # tariff   - Tariff Code
    # tax      - Tax Code associated with this tariff
    # rowver   - Row Version (optimistic locking)
    #
    # NOTE: table is empty in TESTING.FDB
  end
end