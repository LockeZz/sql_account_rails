module SqlAccount
  class PurchaseGoodsReceived < Record
    self.table_name = 'ph_gr'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::GoodsReceivedLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # traceability — GR can originate from a PO
    scope :from_order,   -> { joins(:lines).where("ph_grdtl.fromdoctype = 'PO'").distinct }

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # extra columns vs PO (on top of shared header):
    # landingcost1/2       - Import Landing Costs
    # localtotalwithcost   - Local Total including landing costs
    # d_amount             - Discount Amount
    # NOTE: no peppol fields, no payment fields — GR is pre-invoice
  end
end
