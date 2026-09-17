module SqlAccount
  class GlAccount < Record 

    self.table_name = 'gl_acc'
    self.primary_key = 'dockey'

    belongs_to :parent_account,
      class_name: 'SqlAccount::GlAccount',
      foreign_key: 'parent',
      primary_key: 'dockey',
      optional: true

    has_many :child_accounts,
      class_name: 'SqlAccount::GlAccount',
      foreign_key: 'parent',
      primary_key: 'docket'

    has_many :customer_payments,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'paymentmethod',
      primary_key: 'code'

    scope :top_level, -> { where(parent: -1) }
    scope :by_type, -> (type) { where("TRIM(acctype) = ?", type)}
    scope :capital, -> { by_type('CP') }
    scope :asset, -> { by_type('AS') }
    scope :liability, -> { by_type('LI') }
    scope :expense, -> { by_type('EX') }
    scope :revenue, -> { by_type('RE') }
 
    def top_level?
      parent == -1
    end

  end
end

# columns:
# dockey        - Primary Key (surrogate integer)
# parent        - Parent account dockey (-1 = top level)
# code          - GL Account Code (natural key, e.g. '610-200')
# description   - Account Description
# description2  - Account Description 2
# acctype       - Account Type: CP/AS/LI/EX/RE (padded with spaces)
# specialacctype- Special Account Type
# tax           - Default Tax Code for this account
# cashflowtype  - Cash Flow Type (integer)
# sic           - SIC Code
