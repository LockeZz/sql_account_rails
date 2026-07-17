module SqlAccount
  class StockItemAlt < Record

    self.table_name = 'st_item_alt'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    belongs_to :alt_stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'altcode',
      primary_key: 'code'

    # columns per spec:
    # code    - Product Code (FK to st_item.code)
    # altcode - Alternative Product Code (FK to st_item.code)
  end
end