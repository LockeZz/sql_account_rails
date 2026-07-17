module SqlAccount
  class PurchaseRequestLine < Record 

    self.table_name = 'ph_pqdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_request,
      class_name: 'SqlAccount::PurchaseRequest',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true

    # columns (detail — shared base):
    # dtlkey/dockey/seq/styleid/number
    # itemcode     - FK to st_item.code
    # location/batch/project
    # description/description2/description3 (blob)
    # permitno     - Permit No
    # qty/uom/rate/sqty/suomqty
    # unitprice/deliverydate/disc
    # tax/tariff/taxexemptionreason/irbm_classification/taxrate
    # taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount
    # printable/transferable
    # remark1/remark2
    # NOTE: no fromdoc fields — PQ is the start of the chain

  end
end