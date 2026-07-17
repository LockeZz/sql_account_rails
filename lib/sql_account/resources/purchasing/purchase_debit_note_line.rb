module SqlAccount
  class PurchaseDebitNoteLine < Record
    self.table_name = 'ph_sddtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :debit_note,
      class_name: 'SqlAccount::DebitNote',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true

    # columns (confirmed from sample):
    # dtlkey/dockey/seq/styleid/number
    # itemcode/location/batch/project
    # description/description2/description3 (blob)
    # permitno
    # qty/uom/rate/sqty/suomqty/unitprice/deliverydate/disc
    # tax/tariff/taxexemptionreason/irbm_classification
    # taxrate/taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount
    # landingcost1/2
    # account          - GL Account Code
    # whtax/whtaxrate/whlocaltaxamt/whtaxaccountdr/whtaxaccountcr - Withholding Tax
    # printable/transferable
    # fromdoctype/fromdockey/fromdtlkey - Source doc (detail-level link)
    # remark1/remark2
    # NOTE: fromdoc is on HEADER for ph_sd, but detail also has fromdoctype
  end
end
