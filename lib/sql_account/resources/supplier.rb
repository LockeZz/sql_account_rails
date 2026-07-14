module SqlAccount
  class Supplier < Record 

    self.table_name = "ap_supplier"
    self.primary_key = 'code'

    has_many :branches,
      class_name: 'SqlAccount::SupplierBranch',
      foreign_key: 'code',
      primary_key: 'code'
    
    has_many :bank_accounts,
      class_name: 'SqlAccount::SupplierBankAcc',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :credit_controls,
      class_name: 'SqlAccount::SupplierCrCtrl',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :tariffs,
      class_name: 'SqlAccount::SupplierTariff',
      foreign_key: 'code',
      primary_key: 'code'

    # branch shortcuts
    has_one :billing_branch,
      -> { where("TRIM(branchtype) = 'B'") },
      class_name: 'SqlAccount::SupplierBranch',
      foreign_key: 'code',
      primary_key: 'code'

    has_one :delivery_branch,
      -> { where("TRIM(branchtype) = 'D'") },
      class_name: 'SqlAccount::SupplierBranch',
      foreign_key: 'code',
      primary_key: 'code'

    scope :active,   -> { where("TRIM(status) = 'A'") }
    scope :inactive, -> { where("TRIM(status) = 'I'") }

    validates :code,        presence: true
    validates :companyname, presence: true

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[attachments note]) }

  end
end

#<SqlAccount::Supplier:0x00007f81b8bfe208
#  code: "400-A0001",
#  controlaccount: "400-000",
#  companyname: "ADY INTERNATIONAL PLT",
#  companyname2: nil,
#  companycategory: "----",
#  area: "----",
#  agent: "----",
#  biznature: nil,
#  creditterm: "30 Days",
#  creditlimit: 0.3e5,
#  overduelimit: 0.0,
#  statementtype: "O   ",
#  currencycode: "----",
#  outstanding: 0.248e5,
#  allowexceedcreditlimit: true,
#  addpdctocrlimit: true,
#  agingon: "I   ",
#  status: "A   ",
#  pricetag: nil,
#  creationdate: "2026-06-23",
#  tax: nil,
#  taxexemptno: nil,
#  taxexpdate: nil,
#  brn: nil,
#  brn2: nil,
#  gstno: nil,
#  salestaxno: nil,
#  servicetaxno: nil,
#  tin: nil,
#  idtype: 0,
#  idno: nil,
#  tourismno: nil,
#  sic: nil,
#  submissiontype: 0,
#  irbm_classification: nil,
#  inforequest_uuid: nil,
#  peppolid: nil,
#  businessunit: nil,
#  taxarea: nil,
#  attachments: nil,
#  remark: nil,
#  note: nil,
#  lastmodified: 1782147942> 