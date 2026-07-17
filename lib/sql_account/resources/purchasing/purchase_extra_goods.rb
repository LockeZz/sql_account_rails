module SqlAccount
  class PurchaseExtraGoods < Record
    self.table_name = 'ph_eg'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::PurchaseExtraGoodsLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    scope :from_goods_received, -> { joins(:lines).where("ph_egdtl.fromdoctype = 'GR'").distinct }

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # NOTE: ph_eg (Extra Goods) — same structure as ph_gr (Goods Received).
    # Used for supplementary/extra goods received outside the original PO/GR flow.
    # Table is empty in TESTING.FDB — schema confirmed from column inspection.
    #
    # extra columns vs shared header (same as ph_gr):
    # landingcost1/2/localtotalwithcost - Import costs
    # d_amount - Discount Amount
  end
end
