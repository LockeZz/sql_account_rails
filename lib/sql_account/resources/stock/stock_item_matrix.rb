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

    # columns:
    # code        - Matrix Code (PK, FK to st_item.stockmatrix)
    # description - Matrix Description
    # d0from      - Dimension 0 From index
    # d0to        - Dimension 0 To index
    # d1from      - Dimension 1 From index
    # d1to        - Dimension 1 To index
    # d2from      - Dimension 2 From index
    # d2to        - Dimension 2 To index
    # separator   - Separator character between dimensions
    # d1subcode   - Dimension 1 Sub Codes (Binary/Blob)
    # d2subcode   - Dimension 2 Sub Codes (Binary/Blob)

  end
end
