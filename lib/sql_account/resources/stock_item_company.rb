module SqlAccount
  class StockItemCompany < Record
    self.table_name = 'st_item_company'
    # composite key: code + company + ctype — no surrogate key per spec

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'company',
      primary_key: 'code',
      optional: true

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'company',
      primary_key: 'code',
      optional: true

    # scopes — ctype distinguishes supplier vs customer
    scope :supplier, -> { where(ctype: 'S') }
    scope :customer, -> { where(ctype: 'C') }

    # columns per spec:
    # code            - Product Code (FK to st_item.code)
    # company         - Supplier/Customer Code
    # ctype           - S = Supplier, C = Customer (Fixed/Hardcode)
    # companyitemcode - Supplier/Customer's own Product Code
    # description     - Supplier/Customer Product Description


    def supplier?
      ctype == 'S'
    end

    def customer?
      ctype == 'C'
    end

    def company_record
      supplier? ? supplier : cutomer
    end
    
  end
end
