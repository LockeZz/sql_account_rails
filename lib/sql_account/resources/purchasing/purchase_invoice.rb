module SqlAccount
  class PurchaseInvoice < Record
    self.table_name = 'ph_pi'
    self.primary_key = 'dockey'

    belongs_to :supplier,
      class_name: 'SqlAccount::Supplier',
      foreign_key: 'code',
      primary_key: 'code'

    has_many :lines,
      class_name: 'SqlAccount::PurchaseInvoiceLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # validations — mirrors eStream SDK mandatory fields
    validates :docno,       presence: true
    validates :docdate,     presence: true
    validates :postdate,    presence: true
    validates :code,        presence: true   # supplier account code
    validates :companyname, presence: true   # denormalized supplier name

    # callbacks
    before_destroy :check_not_knocked_off
    after_destroy  :note_gl_reversal_required

    # scopes
    scope :active,       -> { where(cancelled: false) }
    scope :cancelled,    -> { where(cancelled: true) }
    scope :transferable, -> { where(transferable: true) }
    scope :for_supplier, ->(code)      { where(code: code) }
    scope :by_date,      ->(date)      { where(docdate: date) }
    scope :between,      ->(from, to)  { where(docdate: from..to) }
    scope :for_project,  ->(proj)      { where(project: proj) }
    scope :for_currency, ->(curr)      { where(currencycode: curr) }

    # e-Invoice / MyInvois scopes
    scope :eiv_submitted,  -> { where.not(irbm_uuid: nil) }
    scope :eiv_validated,  -> { where.not(irbm_validated_utc: nil) }
    scope :eiv_pending,    -> { where(irbm_uuid: nil) }

    # exclude heavy binary columns by default
    default_scope { select(column_names - %w[attachments note approvestate]) }

    # Safe line update — mirrors eStream SDK pattern (delete all, reinsert)
    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index do |l, i|
        lines.create!(l.merge(seq: l[:seq] || i + 1))
      end
    end

    def cancelled?
      cancelled == true
    end

    def cancel!
      update!(cancelled: true)
    end

    def multi_currency?
      currencycode != '----' && currencycode.present?
    end

    def eiv_submitted?
      irbm_uuid.present?
    end

    def eiv_validated?
      irbm_validated_utc.present?
    end

    private

    # Prevent deletion if document has been knocked off by Payment or Credit Note
    # SDK comment: "Deleting only work if the record never not knock off by Payment or Credit Note"
    def check_not_knocked_off
      if knocked_off?
        errors.add(:base, "Cannot delete Purchase Invoice '#{docno}' — it has been knocked off by a Payment or Credit Note")
        throw(:abort)
      end
    end

    def knocked_off?
      # Check ap_knockoff table for any references to this dockey
      # ap_knockoff links payments/credit notes to invoices
      ActiveRecord::Base.connection.execute(<<~SQL).first.present?
        SELECT FIRST 1 1 FROM ap_knockoff WHERE dockey2 = #{dockey}
      SQL
    rescue
      false
    end

    def note_gl_reversal_required
      Rails.logger.warn(
        "[SqlAccount] PurchaseInvoice #{docno} (dockey: #{dockey}) was hard-deleted. " \
        "GL postings and ST_TR entries were NOT automatically reversed. " \
        "Ledger balances may be inconsistent — verify manually."
      )
    end

    # columns:
    # (2 Unknown computed cols — likely derived totals)
    # dockey           - Primary Key
    # docno            - Document No (business key)
    # docnoex          - External Document No (supplier's own invoice no)
    # docdate          - Document Date
    # postdate         - Post Date
    # taxdate          - Tax Date (for SST reporting)
    # eiv_utc          - e-Invoice Submission UTC timestamp
    # eiv_received_utc - e-Invoice Received UTC timestamp
    # eiv_validated_utc- e-Invoice Validated UTC timestamp
    # code             - Supplier Account Code (FK to ap_supplier.code)
    # companyname      - Supplier Name (denormalized at time of posting)
    # address1-4       - Supplier Billing Address
    # postcode/city/state/country - Billing address components
    # phone1/mobile/fax1/attention - Supplier contact (denormalized)
    # area             - Area
    # agent            - Agent
    # project          - Project
    # terms            - Payment Terms
    # currencycode     - Currency Code ('----' = local currency)
    # currencyrate     - Currency Exchange Rate
    # shipper          - Shipper
    # description      - Document Description
    # cancelled        - Cancelled flag (boolean)
    # status           - Status (integer)
    # docamt           - Document Total Amount (in document currency)
    # localdocamt      - Document Total Amount (in local currency)
    # landingcost1/2   - Import Landing Costs
    # localtotalwithcost - Local Total including landing costs
    # d_amount         - Discount Amount
    # validity         - Validity period
    # deliveryterm     - Delivery Terms
    # cc               - CC
    # docref1-4        - Document References
    # branchname       - Branch Name
    # daddress1-4      - Delivery Address
    # dpostcode/dcity/dstate/dcountry - Delivery address components
    # dattention/dphone1/dmobile/dfax1 - Delivery contact
    # taxexemptno      - Tax Exemption No
    # salestaxno       - Sales Tax Registration No
    # servicetaxno     - Service Tax Registration No
    # tin              - Tax Identification No
    # idtype/idno      - ID Type and No
    # tourismno        - Tourism Tax No
    # sic              - SIC Code
    # incoterms        - Incoterms
    # submissiontype   - Submission Type (integer)
    # irbm_status      - MyInvois/IRBM Status (integer)
    # irbm_internalid  - MyInvois Internal ID
    # irbm_uuid        - MyInvois UUID
    # irbm_longid      - MyInvois Long ID
    # peppol_uuid      - Peppol UUID
    # peppol_docuuid   - Peppol Document UUID
    # businessunit     - Business Unit
    # attachments      - Attachments (Binary/Blob)
    # note             - Notes (Binary/Blob)
    # approvestate     - Approval Workflow State (Binary/Blob)
    # transferable     - Transferable flag (boolean)
    # updatecount      - Update Count
    # printcount       - Print Count
    # lastmodified     - Last Modified (Unix timestamp integer)
  end
end