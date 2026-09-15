module SqlAccount
  class CustomerBranch < Record 

    self.table_name = 'ar_customerbranch'

    belongs_to :customer,
      class_name: 'SqlAccount::Customer',
      foreign_key: 'code',
      primary_key: 'code'

    # scopes
    scope :billing,    -> { where("TRIM(branchtype) = 'B'") }
    scope :delivery,   -> { where("TRIM(branchtype) = 'D'") }
    scope :for_code,   ->(code) { where(code: code) }

    # Branch type constants
    BILLING  = 'B'.freeze
    DELIVERY = 'D'.freeze

    def billing?
      branchtype.strip == BILLING
    end

    def delivery?
      branchtype.strip == DELIVERY
    end

    def full_address
      [address1, address2, address3, address4, postcode, city, state, country]
        .compact
        .reject(&:blank?)
        .join(', ')
    end

    # columns:
    # dtlkey      - Primary Key
    # code        - FK to ar_customer.code
    # branchtype  - 'B' = Billing, 'D' = Delivery (padded with spaces)
    # branchname  - Branch Name
    # address1-4  - Address lines
    # postcode    - Postcode
    # city        - City
    # state       - State
    # country     - Country code (e.g. 'MY')
    # geolat      - Latitude (GPS)
    # geolong     - Longitude (GPS)
    # attention   - Attention/Contact person
    # phone1/2    - Phone numbers
    # mobile      - Mobile number
    # fax1/2      - Fax numbers
    # email       - Email address

  end
end