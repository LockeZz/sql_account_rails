module SqlAccount
  class StockAdjustmentLine < Record
    self.table_name = 'st_ajdtl'
    self.primary_key = 'dtlkey'

    belongs_to :stock_adjustment,
      class_name: 'SqlAccount::StockAdjustment',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    # validations — mirrors eStream SDK mandatory fields
    validates :seq,      presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :itemcode, presence: true
    validates :qty,      presence: true, numericality: true
    validates :uom,      presence: true

    # scopes
    scope :for_item,     ->(code) { where(itemcode: code) }
    scope :increases,    -> { where("qty > 0") }  # stock in
    scope :decreases,    -> { where("qty < 0") }  # stock out
    scope :for_location, ->(loc)  { where(location: loc) }
    scope :for_batch,    ->(batch){ where(batch: batch) }
    scope :printable,    -> { where(printable: true) }

    # columns:
    # (1 Unknown computed col — likely derived amount)
    # dtlkey      - Primary Key
    # dockey      - FK to st_aj.dockey
    # seq         - Line Sequence (starts at 1, set explicitly)
    # styleid     - Matrix Style ID
    # number      - Matrix Number
    # itemcode    - Product Code (FK to st_item.code)
    # location    - Location / Warehouse
    # batch       - Batch No
    # project     - Project
    # description - Item Description
    # description2- Item Description 2
    # description3- Item Description 3 (Binary/Blob)
    # bookqty     - Book Quantity (system balance at time of adjustment)
    # physicalqty - Physical Quantity (actual counted qty)
    # qty         - Adjustment Quantity (physicalqty - bookqty)
    #               positive = increase stock, negative = decrease stock
    # suomqty     - Secondary UOM Quantity (Fixed/Hardcode 0)
    # uom         - Unit of Measurement
    # rate        - UOM Rate
    # sqty        - Secondary Quantity
    # unitcost    - Unit Cost (required for increases, optional for decreases)
    # amount      - Total Amount (qty * unitcost)
    # printable   - Printable flag (boolean)
    # remark1     - Remark 1
    # remark2     - Remark 2


    # Helpers
    def increase?
      qty.positive?
    end

    def decrease?
      qty.negative?
    end

    def total_amount
      qty * unitcost
    end

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[description3 approvestate]) }
  end
end