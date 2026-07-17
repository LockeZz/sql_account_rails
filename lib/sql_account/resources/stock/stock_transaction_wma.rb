module SqlAccount
  class StockTransactionWma < Record
    self.table_name = 'st_tr_wma'
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
    scope :for_item,      ->(code)  { where(itemcode: code) }
    scope :as_of,         ->(date)  { where("postdate <= ?", date) }
    scope :with_balance,  ->        { where("utdqty <> 0") }
    scope :latest_seq,    ->        { where("seq = (SELECT MAX(seq) FROM st_tr_wma b WHERE b.transno = st_tr_wma.transno)") }

    # Weighted average cost for an item as of a given date.
    # Mirrors eStream SDK pattern:
    #   SELECT MAX(B.Seq) FROM ST_TR A
    #   INNER JOIN ST_TR_WMA B ON (A.TRANSNO=B.TRANSNO)
    #   WHERE A.PostDate <= ? AND A.ItemCode = ?
    #   then fetch UTDQty/UTDCost for that seq
    #
    # NOTE: accuracy depends on when "Month End Costing" was last run
    # inside SQL Account's UI. Results reflect the last costing run,
    # not a live real-time calculation.
    def self.weighted_average_for(code, location: nil, batch: nil, as_of: Date.today)
      # find the latest seq for this item across all relevant transactions
      tr_scope = StockTransaction
        .for_item(code)
        .as_of(as_of)

      tr_scope = tr_scope.for_location(location) if location
      tr_scope = tr_scope.for_batch(batch)       if batch

      transno_list = tr_scope.pluck(:transno)
      return { utdqty: 0, utdcost: 0, diffcost: 0 } if transno_list.empty?

      # get the WMA row with the highest seq for these transactions
      latest = where(transno: transno_list)
        .with_balance
        .order(seq: :desc)
        .first

      return { utdqty: 0, utdcost: 0, diffcost: 0 } unless latest

      {
        utdqty:   latest.utdqty,
        utdcost:  latest.utdcost,
        diffcost: latest.diffcost
      }
    end

    # columns:
    # autokey   - Primary Key
    # transno   - FK to st_tr.transno
    # itemcode  - Product Code (FK to st_item.code, denormalized for filtering)
    # postdate  - Post Date (denormalized from st_tr for filtering)
    # seq       - Costing Run Sequence (MAX = most recent run result)
    # utdqty    - Updated Quantity (running stock balance at this transaction)
    # utdcost   - Updated Cost (weighted average unit cost at this transaction)
    # diffcost  - Difference Cost (cost adjustment from costing run)
  end
end