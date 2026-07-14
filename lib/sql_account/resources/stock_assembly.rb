module SqlAccount
  class StockAssembly < Record
    self.table_name = 'st_as'
    self.primary_key = 'dockey'

    belongs_to :finished_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    has_many :lines,
      class_name: 'SqlAccount::StockAssemblyLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    has_many :component_items,
      through: :lines,
      class_name: 'SqlAccount::StockItem',
      source: :stock_item

    # validations — mirrors eStream SDK mandatory fields
    validates :docno,       presence: true
    validates :docdate,     presence: true
    validates :postdate,    presence: true
    validates :itemcode,    presence: true  # finished product (BOM parent)
    validates :qty,         presence: true, numericality: { greater_than: 0 }
    validates :uom,         presence: true

    # callbacks
    after_destroy :note_st_tr_reversal_required

    # scopes
    scope :active,      -> { where(cancelled: false) }
    scope :cancelled,   -> { where(cancelled: true) }
    scope :by_date,     ->(date) { where(docdate: date) }
    scope :between,     ->(from, to) { where(docdate: from..to) }
    scope :for_item,    ->(code) { where(itemcode: code) }
    scope :for_location,->(loc)  { where(location: loc) }
    scope :for_project, ->(proj) { where(project: proj) }
    scope :from_doc,    ->(type, key) { where(fromdoctype: type, fromdockey: key) }

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[attachments note approvestate]) }

    # Safe line update — mirrors eStream SDK pattern (delete all, reinsert)
    # Usage: assembly.update_lines([{ seq: 1, itemcode: 'ANT', qty: 2, uom: 'UNIT' }, ...])
    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index do |l, i|
        lines.create!(l.merge(seq: l[:seq] || i + 1))
      end
    end

    def cancelled?
      cancelled == true
    end

    def cancel!
      update!(cancelled: true)
    end

    private

    # IMPORTANT: Direct DB delete does NOT auto-reverse ST_TR entries.
    # SQL Account's app layer handles this automatically — we don't.
    def note_st_tr_reversal_required
      Rails.logger.warn(
        "[SqlAccount] StockAssembly #{docno} (dockey: #{dockey}) was hard-deleted. " \
        "ST_TR transaction entries were NOT automatically reversed. " \
        "Stock balances may be inconsistent — verify ST_TR manually."
      )
    end

    # columns:
    # (1 Unknown computed col)
    # dockey       - Primary Key
    # docno        - Document No (business key)
    # itemcode     - Finished Product Code (BOM parent, FK to st_item.code)
    # docdate      - Document Date
    # postdate     - Post Date
    # description  - Document Description
    # cancelled    - Cancelled flag (boolean)
    # status       - Status (integer)
    # location     - Output Location for finished goods
    # batch        - Batch No for finished product
    # project      - Project
    # qty          - Finished Product Quantity assembled
    # uom          - Finished Product UOM
    # rate         - UOM Rate
    # sqty         - Secondary Quantity
    # suomqty      - Secondary UOM Quantity
    # asmcost      - Assembly Cost (overhead/labour)
    # multiply     - Assembly Multiplier/Factor
    # docamt       - Document Total Amount
    # attachments  - Attachments (Binary/Blob)
    # authby       - Authorized By
    # reason       - Reason
    # remark       - Remark
    # bompackage   - BOM Package Reference
    # fromdoctype  - Source Document Type (e.g. 'JO' = Job Order)
    # fromdockey   - Source Document Key
    # note         - Notes (Binary/Blob)
    # approvestate - Approval Workflow State (Binary/Blob)
    # updatecount  - Update Count
    # printcount   - Print Count
    # lastmodified - Last Modified (Unix timestamp integer)
  end
end