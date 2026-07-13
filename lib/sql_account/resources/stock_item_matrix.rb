module SqlAccount
  class StockItemMatrix < Record
    self.table_name = 'st_item_matrix'
    # primary key: to be confirmed from actual column inspection

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # NOTE: matrix items are used for products with multiple variants
    # (e.g. size/colour combinations — stockmatrix field in st_item
    # references the matrix template code)
    # Confirm column structure via column inspection before use
  end
end
