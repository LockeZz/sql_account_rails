module SqlAccount
  class StockItemBom < Record
    self.table_name = 'st_item_bom'
    self.primary_key = 'autokey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    belongs_to :sub_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'subcode',
      primary_key: 'code'

    # scopes
    scope :default, -> { where(isdefault: 'T') }
    scope :wastage,  -> { where(iswastage: 'T') }

    # columns per spec:
    # autokey       - Primary Key
    # code          - Product Code (FK to st_item.code)
    # subcode       - Bill Of Material Component Code (FK to st_item.code)
    # location      - Location
    # bompackage    - BOM Package
    # qty           - Quantity required
    # uom           - Component UOM
    # overheadcost  - Overhead Cost
    # refcost       - Reference Cost
    # isdefault     - T/F
    # batch         - Batch No
    # iswastage     - T/F
  end
end
