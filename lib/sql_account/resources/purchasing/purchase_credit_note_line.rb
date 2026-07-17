module SqlAccount
  class PurchaseCreditNoteLine < Record
    self.table_name = 'ph_pcdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_credit_note,
      class_name: 'SqlAccount::PurchaseCreditNote',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,    presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,    presence: true, numericality: true
    validates :uom,    presence: true
    validates :amount, presence: true, numericality: true

    scope :from_invoice,        -> { where(fromdoctype: 'PI') }
    scope :from_purchase_return,-> { where(fromdoctype: 'SC') }

    # columns (confirmed from column inspection, table empty in TESTING.FDB):
    # dtlkey/dockey/seq/styleid/number
    # itemcode/location/batch/project
    # description/description2/description3 (blob)
    # permitno
    # qty/uom/rate/sqty/suomqty/unitprice/disc
    # tax/tariff/taxexemptionreason/irbm_classification
    # taxrate/taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount
    # printable
    # fromdoctype/fromdockey/fromdtlkey - Source doc
    # remark1/remark2
    # NOTE: no account, no whtax, no landingcost, no transferable — simpler than PI/SD detail
  end
end
