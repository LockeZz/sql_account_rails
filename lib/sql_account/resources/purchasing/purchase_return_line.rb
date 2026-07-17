module SqlAccount
  class PurchaseReturnLine < Record
    self.table_name = 'ph_scdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_return,
      class_name: 'SqlAccount::PurchaseReturn',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,    presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,    presence: true, numericality: true
    validates :uom,    presence: true
    validates :amount, presence: true, numericality: true

    scope :from_invoice, -> { where(fromdoctype: 'PI') }

    def from_invoice?
      fromdoctype == 'PI'
    end

    # columns (confirmed from sample):
    # dtlkey/dockey/seq/styleid/number
    # itemcode/location/batch/project
    # description/description2/description3 (blob)
    # permitno
    # qty/uom/sqty/rate/suomqty/unitprice
    # disc/tax/tariff/taxexemptionreason/irbm_classification
    # taxrate/taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount
    # account          - GL Account Code
    # whtax/whtaxrate/whlocaltaxamt/whtaxaccountdr/whtaxaccountcr - Withholding Tax
    # printable
    # fromdoctype      - 'PI' = Purchase Invoice (returns against invoice)
    # fromdockey/fromdtlkey - Source PI keys
    # remark1/remark2
    # NOTE: no transferable field on this detail table
  end
end
