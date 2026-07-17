module SqlAccount
  class PurchaseInvoiceLine < Record
    self.table_name = 'ph_pidtl'
    self.primary_key = 'dtlkey'

    include SqlAccount::PurchaseDocumentLine

    belongs_to :purchase_invoice,
      class_name: 'SqlAccount::PurchaseInvoice',
      foreign_key: 'dockey',
      primary_key: 'dockey'

    belongs_to :stock_item,
      class_name: 'SqlAccount::StockItem',
      foreign_key: 'itemcode',
      primary_key: 'code',
      optional: true   # some lines may be GL account lines (no itemcode)

    # validations — mirrors eStream SDK mandatory fields
    validates :seq,       presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :qty,       presence: true, numericality: true
    validates :uom,       presence: true
    validates :unitprice, presence: true, numericality: true
    validates :amount,    presence: true, numericality: true
    validates :taxamt,    presence: true, numericality: true

    # scopes
    scope :for_item,     ->(code) { where(itemcode: code) }
    scope :for_location, ->(loc)  { where(location: loc) }
    scope :for_batch,    ->(b)    { where(batch: b) }
    scope :for_project,  ->(proj) { where(project: proj) }
    scope :printable,    ->       { where(printable: true) }
    scope :transferable, ->       { where(transferable: true) }
    scope :with_tax,     ->       { where.not(tax: ['', nil]) }
    scope :tax_inclusive,->       { where(taxinclusive: true) }
    scope :from_doc,     ->(type, key) { where(fromdoctype: type, fromdockey: key) }

    # helpers
    def has_tax?
      tax.present?
    end

    def tax_inclusive?
      taxinclusive == true
    end

    def transferable?
      transferable == true
    end

    def net_amount
      amount - taxamt.to_d
    end

    def from_goods_received?
      fromdoctype == 'GR'
    end

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[description3]) }

    # columns:
    # (3 Unknown computed cols — likely derived totals)
    # dtlkey           - Primary Key
    # dockey           - FK to ph_pi.dockey
    # seq              - Line Sequence (set explicitly, starts at 1)
    # styleid          - Matrix Style ID
    # number           - Matrix Number
    # itemcode         - Product Code (FK to st_item.code, optional for GL lines)
    # location         - Location / Warehouse
    # batch            - Batch No
    # project          - Project
    # description      - Item Description
    # description2     - Item Description 2
    # description3     - Rich Text Description (Binary/Blob)
    # permitno         - Permit No
    # qty              - Quantity
    # uom              - Unit of Measurement
    # rate             - UOM Rate
    # sqty             - Secondary Quantity
    # suomqty          - Secondary UOM Quantity
    # unitprice        - Unit Price
    # deliverydate     - Expected Delivery Date
    # disc             - Discount string (e.g. '5%+3')
    # tax              - Tax Code (empty string = no tax)
    # tariff           - Tariff Code
    # taxexemptionreason - Tax Exemption Reason
    # irbm_classification - MyInvois Item Classification Code
    # taxrate          - Tax Rate string
    # taxamt           - Tax Amount
    # localtaxamt      - Local Currency Tax Amount
    # exempted_taxrate - Exempted Tax Rate
    # exempted_taxamt  - Exempted Tax Amount
    # taxinclusive     - Tax Inclusive flag (boolean)
    # amount           - Line Total Amount (excl. tax if not inclusive)
    # localamount      - Local Currency Amount
    # taxableamt       - Taxable Amount
    # im_currencycode  - Import Currency Code
    # im_currencyrate  - Import Currency Rate
    # im_purchaseamt   - Import Purchase Amount
    # landingcost1/2   - Per-line Import Landing Costs
    # account          - GL Account Code override
    # whtax            - Withholding Tax Code
    # whtaxrate        - Withholding Tax Rate
    # whlocaltaxamt    - Withholding Tax Local Amount
    # whtaxaccountdr   - Withholding Tax Debit Account
    # whtaxaccountcr   - Withholding Tax Credit Account
    # printable        - Printable flag (boolean)
    # fromdoctype      - Source Document Type (e.g. 'GR' = Goods Received)
    # fromdockey       - Source Document Key
    # fromdtlkey       - Source Document Detail Key
    # transferable     - Transferable flag (boolean)
    # remark1          - Remark 1
    # remark2          - Remark 2
  end
end