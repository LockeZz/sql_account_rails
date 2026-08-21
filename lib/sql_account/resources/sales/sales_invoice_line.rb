module SqlAccount
  class SalesInvoiceLine < Record 

    self.table_name = "sl_ivdtl"
    self.primary_key = 'dtlkey'

    include SqlAccount::SalesDocumentLine

    belongs_to :sales_invoice,
      class_name: 'SqlAccount::SalesInvoice',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true

    scope :tax_inclusive,     -> { where(taxinclusive: true) }
    scope :from_sales_order,  -> { where(fromdoctype: 'SO') }
    scope :from_delivery,     -> { where(fromdoctype: 'DO') }

    def from_sales_order?
      fromdoctype == 'SO'
    end

    def from_delivery_order?
      fromdoctype == 'DO'
    end

    # columns confirmed from inspection:
    # dtlkey/dockey/seq/styleid/number
    # itemcode/location/batch/project
    # description/description2/description3 (blob)
    # permitno
    # qty/uom/rate/sqty/suomqty
    # unitprice/deliverydate/disc
    # tax/tariff/taxexemptionreason/irbm_classification
    # taxrate/taxamt/localtaxamt/exempted_taxrate/exempted_taxamt/taxinclusive
    # amount/localamount/taxableamt
    # account          - GL Account Code (FK to gl_acc.code)
    # printable/transferable
    # fromdoctype      - Source doc type ('SO' = Sales Order, 'DO' = Delivery Order)
    # fromdockey/fromdtlkey - Source doc keys
    # remark1/remark2
    # initialpurchasecost - Original purchase cost (for margin/GP analysis)
    #                       gross_profit = amount - (initialpurchasecost * qty)

  end
end