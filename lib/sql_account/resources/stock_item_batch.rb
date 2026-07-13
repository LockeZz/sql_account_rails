module SqlAccount
  class StockItemBatch < Record
    self.table_name = 'st_item_batch'
    # primary key: to be confirmed from actual column inspection

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # NOTE: batch tracking for items with serialnumber/batch control enabled
    # Confirm column structure via column inspection before use
  end
end
