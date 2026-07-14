module SqlAccount 
  class SupplierBranch < Record 

    self.table_name = 'ap_supplierbranch'
    self.primary_key = 'dtlkey'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code'

    scope :billing, -> { where("TRIM(branchtype) = 'B'")}
    scope :delivery, -> { where("TRIM(branchtype) = 'D'")}

    validates :code, presence: true
    validates :branchtype, presence: true

    # columns:
    # dtlkey     - Primary Key
    # code       - Supplier Code (FK to ap_supplier.code)
    # branchtype - B = Billing, D = Delivery
    # branchname - Branch Name
    # address1~4 - Address lines
    # postcode   - Postcode
    # city       - City
    # state      - State
    # country    - Country
    # geolat     - GPS Latitude
    # geolong    - GPS Longitude
    # attention  - Contact Person
    # phone1~2   - Phone numbers
    # mobile     - Mobile
    # fax1~2     - Fax numbers
    # email      - Email
  end
end