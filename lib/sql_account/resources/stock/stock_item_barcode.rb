module SqlAccount
  class StockItemBarcode < Record

    self.table_name = 'st_item_barcode'
    self.primary_key = 'autokey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # columns per spec:
    # autokey  - Primary Key (Fixed/Hardcode -1 on create)
    # barcode  - Barcode string
    # code     - Product Code (FK to st_item.code)
    # uom      - Product Unit of Measurement

  end
end