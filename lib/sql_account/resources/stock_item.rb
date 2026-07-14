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

    # BATCH AND MATRIX SEEMS TO BE NOT RELEVANT HERE. PENDING TO CHECK
    has_many :matrices,
      class_name: 'SqlAccount::StockItemMatrix',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :batch_memberships,
      class_name: 'SqlAccount::StockItemBatch',
      foreign_key: 'itemcode',
      primary_key: 'code'

    has_many :batches,
      through: :batch_memberships,
      class_name: 'SqlAccount::StockBatch',
      source: :stock_batch

    has_many :opening_balances,
      class_name: 'SqlAccount::StockItemOb',
      foreign_key: 'itemcode',
      primary_key: 'code'

    has_many :templates,
      class_name: 'SqlAccount::StockItemTpl',
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

    
    validates :code, presence: true
    validates :description, presence: true
    validates :stockgroup, presence: true
    validates :stockcontrol, presence: true
    validates :isactive, presence: true, inclusion: { in: %w[T F] }

    before_destroy :check_not_used_in_transactions

    scope :active,        -> { where(isactive: 'T') }
    scope :inactive,      -> { where(isactive: 'F') }
    scope :stock_control, -> { where(stockcontrol: 'T') }
    scope :with_serial,   -> { where(serialnumber: 'T') }
    scope :bom_items,     -> { where(itemtype: 'B') }
    scope :normal_items,  -> { where(itemtype: '-') }
    
    # exclude heavy binary columns from default queries
    default_scope { select(column_names - %w[picture attachments note description3]) }
    

    # Stock balance helpers — derived from ST_TR (stock transaction ledger)
    # More accurate than balsqty (cached column) for historical/filtered queries
    def balance(location: nil, batch: nil, project: nil, as_of: Date.today)
      SqlAccount::StockTransaction.balance_for(
        code,
        location: location,
        batch: batch,
        project: project,
        as_of: as_of
      )
    end

    def stock_value(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransaction.stock_value_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end

    def balance_by_location(as_of: Date.today)
      SqlAccount::StockTransaction.balance_by_location(code, as_of: as_of)
    end

    def balance_by_batch(location: nil, as_of: Date.today)
      SqlAccount::StockTransaction.balance_by_batch(code, location: location, as_of: as_of)
    end

    # Weighted average cost — derived from ST_TR_WMA (month-end costing table)
    # NOTE: only as accurate as the last time "Month End Costing" was run
    # inside SQL Account's UI. Not a live real-time calculation.
    # Returns: { utdqty:, utdcost:, diffcost: }
    def weighted_average_cost(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransactionWma.weighted_average_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end

    def costing_snapshot(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransactionWma.snapshot_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end

    # FIFO cost — from ST_TR_FIFO (month end costing table)
    # Only relevant for items with costingmethod = FIFO
    # Only accurate after "Month End Costing" has been run in SQL Account UI
    def fifo_cost(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransactionFifo.fifo_cost_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end

    def fifo_cost_layers(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransactionFifo.cost_layers_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end

    def fifo_stock_value(location: nil, batch: nil, as_of: Date.today)
      SqlAccount::StockTransactionFifo.stock_value_for(
        code,
        location: location,
        batch: batch,
        as_of: as_of
      )
    end


    # Safe UOM update — mirrors eStream SDK pattern (delete all, reinsert)
    # Usage: item.update_uoms([{ uom: 'PCS', rate: 1, refcost: 10, refprice: 25, isbase: 1 }, ...])
    def update_uoms(uom_list)
      uoms.delete_all
      uom_list.each { |u| uoms.create!(u) }
    end

    # Safe barcode update — mirrors eStream SDK pattern (delete all, reinsert)
    # Usage: item.update_barcodes([{ barcode: '123456', uom: 'PCS' }, ...])
    def update_barcodes(barcode_list)
      barcodes.delete_all
      barcode_list.each { |b| barcodes.create!(b) }
    end


    private

    # Prevent deletion if item has been used in any transaction document.
    # SQL Account itself enforces this at the app layer — we mirror it here.
    # TODO: expand check to all document detail tables once modeled
    # (sl_iv dtl, sl_do dtl, ph_gr dtl, st_aj dtl, st_xf dtl, etc.)
    def check_not_used_in_transactions
      if used_in_transactions?
        errors.add(:base, "Cannot delete stock item '#{code}' — it has been used in transaction documents")
        throw(:abort)
      end
    end

    def used_in_transactions?
      # Placeholder — returns false until document tables are fully modeled.
      # Once SL_IV, PH_GR, ST_AJ etc. are mapped, add checks like:
      # SalesInvoiceLine.where(itemcode: code).exists? ||
      # PurchaseGoodReceiptLine.where(itemcode: code).exists?
      false
    end

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

