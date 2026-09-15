module SqlAccount
  class Customer < Record 

    self.table_name = "ar_customer"
    self.primary_key = "code"

    has_many :branches,
      class_name: 'SqlAccount::CustomerBranch',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :bank_accounts,
      class_name: 'SqlAccount::CustomerBankAcc',
      foreign_key: 'code',
      primary_key: 'code'
    
    has_one :billing_branch, -> { where("TRIM(branchtype) = 'B'") },
      class_name: 'SqlAccount::CustomerBranch',
      foreign_key: 'code',
      primary_key: 'code'

    has_one :delivery_branch, -> { where("TRIM(branchtype) = 'D'") },
      class_name: 'SqlAccount::CustomerBranch',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :item_listings, -> { where(ctype: 'C') },
      class_name: 'SqlAccount::StockItemCompany',
      foreign_key: 'company',
      primary_key: 'code'

    has_many :purchased_items, through: :item_listings,
      class_name: 'SqlAccount::StockItem',
      source: :stock_item

    has_many :item_prices, -> { where(tagtype: 'C') },
      class_name: 'SqlAccount::StockItemPrice',
      foreign_key: 'company',
      primary_key: 'code'

    has_many :sales_invoices,
      class_name: 'SqlAccount::SalesInvoice',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :payments,
      class_name: 'SqlAccount::CustomerPayment',
      foreign_key: 'code',
      primary_key: 'code'

    scope :active, -> { where("TRIM(status) = 'A'") }
    scope :inactive, -> { where("TRIM(status) = 'I'") }
    scope :overdue, -> { where('outstanding > overduelimit') }
    scope :over_limit, -> { where(allowexceedcreditlimit: false).where("outstanding > creditlimit") }

    validates :code, presence: true
    validates :companyname, presence: true

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[attachments note]) }

    def active?
      status.strip == 'A'
    end

    def over_credit_limit?
      !allowexceedcreditlimit && outstanding.to_d > creditlimit.to_d 
    end

    def over_overdue_limit?
      outstanding.to_d > overduelimit.to_d
    end

    def aging_by_invoice?
      agingon.strip == 'I'
    end

    def aging_by_payment?
      agingon.strip == 'P'
    end

    # columns:
    # (2 Unknown computed cols)
    # code                  - Customer Account Code (PK, e.g. '300-B0001')
    # controlaccount        - GL Control Account (e.g. '300-000')
    # companyname           - Company Name
    # companyname2          - Company Name 2
    # companycategory       - Company Category
    # area                  - Area
    # agent                 - Agent
    # biznature             - Business Nature
    # creditterm            - Credit Term (e.g. '30 Days')
    # creditlimit           - Credit Limit
    # overduelimit          - Overdue Limit
    # statementtype         - Statement Type ('O' = Outstanding, 'A' = All)
    # currencycode          - Currency Code ('----' = local)
    # outstanding           - Current Outstanding Balance (cached/denormalized)
    # allowexceedcreditlimit- Allow Exceed Credit Limit (boolean)
    # addpdctocrlimit       - Add PDC to Credit Limit (boolean)
    # agingon               - Aging On: 'I' = Invoice Date, 'P' = Payment Date
    # status                - Status: 'A' = Active, 'I' = Inactive (padded)
    # pricetag              - Default Price Tag
    # creationdate          - Creation Date
    # tax                   - Default Tax Code
    # taxexemptno           - Tax Exemption No
    # taxexpdate            - Tax Exemption Expiry Date
    # brn                   - Business Registration No
    # brn2                  - Business Registration No 2
    # gstno                 - GST Registration No
    # salestaxno            - Sales Tax Registration No
    # servicetaxno          - Service Tax Registration No
    # tin                   - Tax Identification No
    # idtype                - ID Type (integer)
    # idno                  - ID No
    # tourismno             - Tourism Tax No
    # sic                   - SIC Code
    # submissiontype        - e-Invoice Submission Type
    # irbm_classification   - MyInvois Classification
    # inforequest_uuid      - Info Request UUID
    # peppolid              - Peppol ID
    # businessunit          - Business Unit
    # taxarea               - Tax Area
    # attachments           - Attachments (Binary/Blob)
    # remark                - Remark
    # note                  - Notes (Binary/Blob)
    # lastmodified          - Last Modified (Unix timestamp)

  end
end