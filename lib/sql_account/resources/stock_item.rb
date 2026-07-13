module SqlAccount
  class StockItem < Record 

    self.table_name = "st_item"
    # self.primary_key = 'code'

    # companion table associations (to add once we model those tables)
    # has_many :prices,    foreign_key: 'itemcode', class_name: 'SqlAccount::StockItemPrice'
    # has_many :uoms,      foreign_key: 'itemcode', class_name: 'SqlAccount::StockItemUom'
    # has_many :barcodes,  foreign_key: 'itemcode', class_name: 'SqlAccount::StockItemBarcode'

    # exclude heavy binary columns from default queries
    default_scope { select(column_names - %w[picture attachments note description3]) }

    # convenience scopes
    scope :active,   -> { where(isactive: 'T') }
    scope :inactive, -> { where(isactive: 'F') }

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

