module SqlAccount
  class StockItemOb < Record
    self.table_name = 'st_item_ob'
    self.primary_key = 'dockey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    # columns per spec:
    # dockey   - Primary Key
    # itemcode - Product Code (FK to st_item.code)
    # location - Location
    # project  - Project
    # seq      - Line Sequence for different Cost
    # qty      - Opening Quantity
    # suomqty  - Secondary UOM Quantity (Fixed/Hardcode 0)
    # cost     - Unit Cost
    # utdcost  - Updated Cost (Qty * Cost)
    # batch    - Batch No
  end
end
