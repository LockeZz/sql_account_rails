module SqlAccount
  class StockItemTpl < Record
    self.table_name = 'st_item_tpl'
    # primary key: to be confirmed from actual column inspection
    # likely 'code' or a surrogate key

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :template_details,
      class_name: 'SqlAccount::StockItemTpldtl',
      foreign_key: 'code',
      primary_key: 'code'

    # NOTE: columns not fully documented in spec — confirm via column inspection
    # against your actual database before relying on this model
  end
end
