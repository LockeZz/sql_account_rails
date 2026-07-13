module SqlAccount
  class StockItemUom < Record
    self.table_name = 'st_item_uom'
    # primary key: composite (code + uom) — no single surrogate key
    # use find_by(code:, uom:) for lookups

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'code',
      primary_key: 'code'

    # scopes
    scope :base_uom, -> { where(isbase: 1) }
    scope :non_base, -> { where(isbase: 0) }

    # columns per spec:
    # code       - Product Code (FK to st_item.code)
    # uom        - Unit of Measurement
    # rate       - UOM Rate relative to base
    # refcost    - Reference Cost
    # refprice   - Reference Price
    # mincost    - Minimum Cost
    # maxcost    - Maximum Cost
    # minprice   - Minimum Price
    # maxprice   - Maximum Price
    # isbase     - 1 = Base UOM, 0 = Non-Base UOM
  end
end
