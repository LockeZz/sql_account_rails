module SqlAccount
  class StockItemCompany < Record
    self.table_name = 'st_item_company'
    # composite key: code + company + ctype — no surrogate key per spec

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # scopes — ctype distinguishes supplier vs customer
    scope :supplier, -> { where(ctype: 'S') }
    scope :customer, -> { where(ctype: 'C') }

    # columns per spec:
    # code            - Product Code (FK to st_item.code)
    # company         - Supplier/Customer Code
    # ctype           - S = Supplier, C = Customer (Fixed/Hardcode)
    # companyitemcode - Supplier/Customer's own Product Code
    # description     - Supplier/Customer Product Description
  end
end
