module SqlAccount
  class CustomerBranch < Record 

    self.table_name = 'ar_customerbranch'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

  end
end