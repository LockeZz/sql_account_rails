module SqlAccount
  module SalesDocument
    extend ActiveSupport::Concern

    included do 
      include SqlAccount::Auditable
      include SqlAccount::DateValidation

      self.sql_account_module = SqlAccount::Audit::MODULE_SL

      belongs_to :customer,
        class_name: 'SqlAccount::Customer',
        foreign_key: 'code',
        primary_key: 'code',
        optional: true

      # belongs_to :project,
      #   class_name: 'Sqla'


    end
  
  end
end