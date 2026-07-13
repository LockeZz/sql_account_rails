module SqlAccount
  class StockItemTpldtl < Record
    self.table_name = 'st_item_tpldtl'
    # primary key: to be confirmed from actual column inspection

    belongs_to :stock_item_tpl,
      class_name: 'SqlAccount::StockItemTpl',
      foreign_key: 'code',
      primary_key: 'code'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # NOTE: columns not fully documented in spec — confirm via column inspection
    # against your actual database before relying on this model
  end
end
