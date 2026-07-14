module SqlAccount
  class StockTransactionFifo < Record
    self.table_name = 'st_tr_fifo'
    self.primary_key = 'autokey'

    belongs_to :stock_transaction,
      class_name: 'SqlAccount::StockTransaction',
      foreign_key: 'transno',
      primary_key: 'transno'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code'

    # scopes
    scope :for_item,   ->(code) { where(itemcode: code) }
    scope :as_of,      ->(date) { where("postdate <= ?", date) }
    scope :with_stock, ->       { where("qty <> 0") }
    scope :latest_seq, ->       { where("seq = (SELECT MAX(b.seq) FROM st_tr_fifo b WHERE b.transno = st_tr_fifo.transno)") }

    # Cost types observed:
    # 'I' = In  (stock received — establishes a cost layer)
    # 'O' = Out (stock consumed — draws from earliest cost layer)
    scope :inbound,  -> { where(costtype: 'I') }
    scope :outbound, -> { where(costtype: 'O') }

    # FIFO cost for an item as of a given date
    # Returns the cost of the oldest unconsumed stock layer (true FIFO)
    #
    # IMPORTANT: same caveat as WMA — only accurate after "Month End Costing"
    # has been run inside SQL Account's UI. Not a live/real-time calculation.
    def self.fifo_cost_for(code, location: nil, batch: nil, as_of: Date.today)
      scope = joins(:stock_transaction)
        .where(itemcode: code)
        .where("st_tr_fifo.postdate <= ?", as_of)
        .inbound
        .with_stock

      scope = scope.where("st_tr.location = ?", location) if location
      scope = scope.where("st_tr.batch = ?", batch)       if batch

      # oldest unconsumed layer = lowest costseq with remaining qty
      oldest_layer = scope.order("costseq ASC").first
      oldest_layer&.cost
    end

    # All unconsumed FIFO cost layers for an item — useful for full valuation
    def self.cost_layers_for(code, location: nil, batch: nil, as_of: Date.today)
      scope = joins(:stock_transaction)
        .where(itemcode: code)
        .where("st_tr_fifo.postdate <= ?", as_of)
        .inbound
        .with_stock

      scope = scope.where("st_tr.location = ?", location) if location
      scope = scope.where("st_tr.batch = ?", batch)       if batch

      scope.order("costseq ASC").map do |layer|
        { costseq: layer.costseq, qty: layer.qty, cost: layer.cost, total: layer.qty * layer.cost }
      end
    end

    # Total FIFO stock value (sum of all unconsumed layers)
    def self.stock_value_for(code, location: nil, batch: nil, as_of: Date.today)
      layers = cost_layers_for(code, location: location, batch: batch, as_of: as_of)
      layers.sum { |l| l[:total] }
    end

    # columns:
    # autokey   - Primary Key
    # transno   - FK to st_tr.transno
    # itemcode  - Product Code (FK to st_item.code, denormalized for query performance)
    # postdate  - Post Date (denormalized from st_tr for query performance)
    # seq       - Costing Run Sequence — MAX(seq) = most recent costing run result
    # costtype  - Cost Layer Type: 'I' = Inbound (received), 'O' = Outbound (consumed)
    # costseq   - Cost Layer Sequence — lower = older layer (consumed first in FIFO)
    # qty       - Remaining Quantity in this cost layer (0 = fully consumed)
    # cost      - Unit Cost of this cost layer
    #
    # NOTE: this table is only populated after running "Month End Costing"
    # inside SQL Account's UI. An empty table means costing has never been run.
    # Only relevant for items with costingmethod = FIFO (check st_item.costingmethod).
  end
end