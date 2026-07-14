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

    # columns:
    # (Unknown computed col)
    # dtlkey       - Primary Key
    # code         - Template Code (FK to st_item_tpl.code)
    # seq          - Line Sequence
    # styleid      - Matrix Style ID
    # number       - Matrix Number
    # itemcode     - Product Code (FK to st_item.code)
    # location     - Location
    # project      - Project
    # description  - Item Description
    # description2 - Item Description 2
    # description3 - Item Description 3 (Binary/Blob)
    # qty          - Quantity
    # suomqty      - Secondary UOM Quantity
    # uom          - Unit of Measurement
    # unitamount   - Unit Amount
    # disc         - Discount
    # amount       - Total Amount
    # printable    - Printable flag (boolean)
    # remark1      - Remark 1
    # remark2      - Remark 2

  end
end
