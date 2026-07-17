module SqlAccount
  class PurchaseGoodsReceivedLine < Record
    self.table_name = 'ph_grdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :goods_received,
      class_name: 'SqlAccount::GoodsReceived',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,    presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,    presence: true, numericality: true
    validates :uom,    presence: true

    scope :from_order,   -> { where(fromdoctype: 'PO') }
    scope :with_returns, -> { where("returnqty > 0") }

    def from_order?
      fromdoctype == 'PO'
    end

    def net_qty
      (receiveqty || 0) - (returnqty || 0)
    end

    # extra columns vs PO detail:
    # receiveqty   - Quantity physically received
    # returnqty    - Quantity returned at time of receipt
    # qty          - Net quantity = receiveqty - returnqty (posted to ST_TR)
    # landingcost1/2 - Per-line import landing costs
    # fromdoctype  - Source doc type ('PO' = Purchase Order)
    # fromdockey   - Source PO dockey
    # fromdtlkey   - Source PO detail dtlkey
    # NOTE: no whtax, no im_currency, no account fields (those appear on PI)
  end
end
