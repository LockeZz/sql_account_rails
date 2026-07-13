module SqlAccount
  class StockItemCategory< Record

    self.table_name = "st_item_category"

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

  end
end

