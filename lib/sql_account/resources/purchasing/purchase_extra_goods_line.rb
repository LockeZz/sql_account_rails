module SqlAccount
  class PurchaseExtraGoodsLine < Record
    self.table_name = 'ph_egdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_extra_goods,
      class_name: 'SqlAccount::PurchaseExtraGoods',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,    presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,    presence: true, numericality: true
    validates :uom,    presence: true

    scope :from_goods_received, -> { where(fromdoctype: 'GR') }

    def net_qty
      (receiveqty || 0) - (returnqty || 0)
    end

    # columns (identical to ph_grdtl — confirmed from column inspection):
    # dtlkey/dockey/seq/styleid/number
    # itemcode/location/batch/project
    # description/description2/description3 (blob)
    # permitno
    # receiveqty   - Quantity physically received
    # returnqty    - Quantity returned at receipt
    # qty          - Net quantity (receiveqty - returnqty)
    # uom/rate/sqty/suomqty/unitprice/disc
    # tax/tariff/taxexemptionreason/irbm_classification
    # taxrate/taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount
    # landingcost1/2
    # printable/transferable
    # fromdoctype/fromdockey/fromdtlkey - Source doc (likely 'GR')
    # remark1/remark2
  end
end
