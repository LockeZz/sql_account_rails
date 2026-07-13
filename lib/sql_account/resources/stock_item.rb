module SqlAccount
  class StockItem < Record 

    self.table_name = 'st_item'
    self.primary_key = 'dockey'

    belongs_to :stock_group,
      class_name: 'SqlAccount::StockGroup',
      foreign_key: 'stockgroup',
      primary_key: 'code'

    has_many :uoms,
      class_name: 'SqlAccount::StockItemUom',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :barcodes,
      class_name: 'SqlAccount::StockItemBarcode',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :bom_lines,
      class_name: 'SqlAccount::StockItemBom',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :alt_items,
      class_name: 'SqlAccount::StockItemAlt',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :categories,
      class_name: 'SqlAccount::StockItemCategory',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :supplier_items,
      -> { where(ctype: 'S') },
      class_name: 'SqlAccount::StockItemCompany',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :customer_items,
      -> { where(ctype: 'C') },
      class_name: 'SqlAccount::StockItemCompany',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :supplier_prices,
      -> { where(tagtype: 'S') },
      class_name: 'SqlAccount::StockItemPrice',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :customer_prices,
      -> { where(tagtype: 'C') },
      class_name: 'SqlAccount::StockItemPrice',
      foreign_key: 'code',
      primary_key: 'code'

    # exclude heavy binary columns from default queries
    default_scope { select(column_names - %w[picture attachments note description3]) }

    scope :active,        -> { where(isactive: 'T') }
    scope :inactive,      -> { where(isactive: 'F') }
    scope :stock_control, -> { where(stockcontrol: 'T') }
    scope :with_serial,   -> { where(serialnumber: 'T') }
    scope :bom_items,     -> { where(itemtype: 'B') }
    scope :normal_items,  -> { where(itemtype: '-') }

  end
end

# #<SqlAccount::StockItem:0x00007f205f78ede0
#  dockey: 66,
#  code: "WS/Wood-Chairs",
#  description: "Good Quality Stackable Wood Stool Chairs (Wood)",
#  description2: nil,
#  stockgroup: "FURNITURE",
#  stockcontrol: true,
#  costingmethod: 1,
#  serialnumber: false,
#  remark1: nil,
#  remark2: nil,
#  minqty: 0.0,
#  maxqty: 0.0,
#  reorderlevel: 0.0,
#  reorderqty: 0.1e1,
#  shelf: nil,
#  suom: nil,
#  itemtype: "-   ",
#  leadtime: 0,
#  bom_leadtime: 0,
#  bom_asmcost: 0.0,
#  sltax: nil,
#  phtax: nil,
#  tariff: nil,
#  irbm_classification: "022",
#  stockmatrix: nil,
#  defuom_st: nil,
#  defuom_sl: nil,
#  defuom_ph: nil,
#  scriptcode: nil,
#  isactive: true,
#  balsqty: 0.3e2,
#  balsuomqty: 0.0,
#  creationdate: "2026-06-23",
#  pictureclass: nil,
#  lastmodified: 1782147938> 

