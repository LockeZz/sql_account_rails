module SqlAccount
  class PurchaseOrderLine < Record
    self.table_name = 'ph_podtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_order,
      class_name: 'SqlAccount::PurchaseOrder',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true

    scope :from_request, -> { where(fromdoctype: 'PQ') }
    scope :pending,      -> { where("offsetqty < qty") }
    scope :fully_received, -> { where("offsetqty >= qty") }

    def from_request?
      fromdoctype == 'PQ'
    end

    def outstanding_qty
      (qty || 0) - (offsetqty || 0)
    end

    def fully_received?
      outstanding_qty <= 0
    end

    # extra columns vs PQ detail:
    # offsetqty    - Quantity already received/transferred to GR
    #                used to track partial fulfilment of a PO line
    # fromdoctype  - Source doc type (e.g. 'PQ' = Purchase Request)
    # fromdockey   - Source doc key
    # fromdtlkey   - Source doc detail key
  end
end
