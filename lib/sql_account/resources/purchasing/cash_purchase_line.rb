module SqlAccount
  class CashPurchaseLine < Record
    self.table_name = 'ph_cpdtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :cash_purchase,
      class_name: 'SqlAccount::CashPurchase',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true

    scope :tax_inclusive, -> { where(taxinclusive: true) }

    # extra columns vs GR detail (same as PI detail — full tax + GL + import):
    # taxableamt       - Taxable Amount
    # im_currencycode  - Import Currency Code
    # im_currencyrate  - Import Currency Rate
    # im_purchaseamt   - Import Purchase Amount
    # landingcost1/2   - Per-line landing costs
    # account          - GL Account Code override
    # whtax/whtaxrate/whlocaltaxamt - Withholding Tax fields
    # whtaxaccountdr/whtaxaccountcr - Withholding Tax GL accounts
    # fromdoctype/fromdockey/fromdtlkey - Source doc (if transferred from GR)
  end
end
