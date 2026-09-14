module SqlAccount
  class CustomerBankAcc < Record 

    self.table_name = 'ar_customerbankacc'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

  end
end