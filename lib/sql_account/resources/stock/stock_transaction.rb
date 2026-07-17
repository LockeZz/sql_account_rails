module SqlAccount
  class StockTransaction < Record
    self.table_name = 'st_tr'
    self.primary_key = 'transno'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    # scopes
    scope :for_item,     ->(code)     { where(itemcode: code) }
    scope :as_of,        ->(date)     { where("postdate <= ?", date) }
    scope :for_location, ->(location) { where(location: location) }
    scope :for_batch,    ->(batch)    { where(batch: batch) }
    scope :for_project,  ->(project)  { where(project: project) }
    scope :for_doctype,  ->(doctype)  { where(doctype: doctype) }

    # Doc types observed in SQL Account:
    # 'OB'  - Opening Balance
    # 'IV'  - Sales Invoice
    # 'DO'  - Delivery Order
    # 'GR'  - Goods Received
    # 'PI'  - Purchase Invoice
    # 'AJ'  - Stock Adjustment
    # 'XF'  - Stock Transfer
    # 'CS'  - Cash Sales
    # 'CN'  - Credit Note
    scope :opening_balance, -> { for_doctype('OB') }
    scope :sales,           -> { where(doctype: %w[IV DO CS]) }
    scope :purchases,       -> { where(doctype: %w[GR PI]) }
    scope :adjustments,     -> { for_doctype('AJ') }
    scope :transfers,       -> { for_doctype('XF') }

    # columns:
    # transno     - Primary Key
    # itemcode    - Product Code (FK to st_item.code)
    # postdate    - Post Date
    # doctype     - Document Type:
    #               'OB' = Opening Balance
    #               'IV' = Sales Invoice
    #               'DO' = Delivery Order
    #               'GR' = Goods Received
    #               'PI' = Purchase Invoice
    #               'AJ' = Stock Adjustment
    #               'XF' = Stock Transfer
    #               'CS' = Cash Sales
    #               'CN' = Credit Note
    # dockey      - FK to document header (e.g. st_aj.dockey, sl_iv.dockey)
    # dtlkey      - FK to document detail line
    # location    - Location / Warehouse
    # area        - Area
    # agent       - Agent
    # project     - Project
    # batch       - Batch No
    # qty         - Quantity (positive = in, negative = out)
    # cost        - Unit Cost
    # price       - Unit Price
    # docno       - Document No (denormalized for reporting)
    # description - Description (denormalized for reporting)
    # refto       - Reference To (links to source transaction)


    # Balance calculation — mirrors eStream SDK pattern:
    # SELECT SUM(qty) FROM ST_TR WHERE postdate <= ? AND itemcode = ?
    # grouped optionally by location and/or batch
    def self.balance_for(code, location: nil, batch: nil, project: nil, as_of: Date.today)
      scope = for_item(code).as_of(as_of)
      scope = scope.for_location(location) if location
      scope = scope.for_batch(batch)       if batch
      scope = scope.for_project(project)   if project
      scope.sum(:qty)
    end

    # Cost value of stock on hand
    def self.stock_value_for(code, location: nil, batch: nil, as_of: Date.today)
      scope = for_item(code).as_of(as_of)
      scope = scope.for_location(location) if location
      scope = scope.for_batch(batch)       if batch
      scope.sum('qty * cost')
    end

    # Breakdown by location — useful for multi-warehouse setups
    def self.balance_by_location(code, as_of: Date.today)
      for_item(code)
        .as_of(as_of)
        .group(:location)
        .sum(:qty)
    end

    # Breakdown by batch — useful for batch-tracked items
    def self.balance_by_batch(code, location: nil, as_of: Date.today)
      scope = for_item(code).as_of(as_of)
      scope = scope.for_location(location) if location
      scope.group(:batch).sum(:qty)
    end
  end
end