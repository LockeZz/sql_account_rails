module SqlAccount
  class StockItemCategory < Record
    self.table_name = 'st_item_category'
    # composite key: code + category — no surrogate key per spec

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # columns per spec:
    # code     - Product Code (FK to st_item.code)
    # category - Category Code (FK to maintain category)
  end
end
