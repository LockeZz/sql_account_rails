module SqlAccount
  class StockItemPrice < Record
    self.table_name = 'st_item_price'
    self.primary_key = 'dtlkey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # scopes — tagtype distinguishes supplier vs customer price
    scope :supplier, -> { where(tagtype: 'S') }
    scope :customer, -> { where(tagtype: 'C') }
    scope :active,   -> { where("datefrom <= ? AND (dateto IS NULL OR dateto >= ?)", Date.today, Date.today) }

    # columns per spec:
    # dtlkey     - Primary Key
    # code       - Product Code (FK to st_item.code)
    # tagtype    - S = Supplier Price, C = Customer Price
    # company    - Supplier/Customer Code (optional)
    # seq        - Line Sequence
    # pricetag   - Price Tag Code
    # uom        - Product UOM
    # qty        - Quantity tier
    # stockvalue - Price Tag Price
    # discount   - Discount
    # datefrom   - Valid From Date
    # dateto     - Valid To Date
    # note       - Notes (Blob)
  end
end
