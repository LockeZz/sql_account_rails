module SqlAccount
  class StockAssemblyLine < Record
    self.table_name = 'st_asdtl'
    self.primary_key = 'dtlkey'

    belongs_to :stock_assembly,
      class_name: 'SqlAccount::StockAssembly',
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
    scope :for_location, ->(loc)  { where(location: loc) }
    scope :for_batch,    ->(b)    { where(batch: b) }
    scope :wastage,      ->       { where(iswastage: true) }
    scope :non_wastage,  ->       { where(iswastage: false) }
    scope :printable,    ->       { where(printable: true) }

    # helpers
    def wastage?
      iswastage == true
    end

    def total_amount
      (qty || 0) * (unitcost || 0) + (overheadcost || 0)
    end

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[description3]) }

    # columns:
    # (2 Unknown computed cols)
    # dtlkey       - Primary Key
    # dockey       - FK to st_as.dockey
    # seq          - Line Sequence (set explicitly, starts at 1)
    # styleid      - Matrix Style ID
    # number       - Matrix Number
    # itemcode     - Component Item Code (FK to st_item.code)
    # location     - Component Source Location
    # batch        - Component Batch No
    # project      - Project
    # description  - Component Description
    # description2 - Component Description 2
    # description3 - Rich Text Description (Binary/Blob — use PlainTextToRichText in SDK)
    # bomqty       - Planned BOM Quantity (from BOM definition)
    # qty          - Actual Quantity consumed in this assembly
    # suomqty      - Secondary UOM Quantity
    # uom          - Component UOM
    # rate         - UOM Rate
    # sqty         - Secondary Quantity
    # unitcost     - Component Unit Cost
    # overheadcost - Overhead Cost allocated to this component
    # amount       - Total Amount (qty * unitcost + overheadcost)
    # iswastage    - Wastage flag (boolean) — marks lines as wastage material
    # printable    - Printable flag (boolean)
    # remark1      - Remark 1
    # remark2      - Remark 2
  end
end