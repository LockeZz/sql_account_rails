module SqlAccount
  class CashPurchase < Record
    self.table_name = 'ph_cp'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::CashPurchaseLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # e-Invoice / MyInvois scopes
    scope :eiv_submitted,  -> { where.not(irbm_uuid: nil) }
    scope :eiv_validated,  -> { where.not(eiv_validated_utc: nil) }

    def eiv_submitted?
      respond_to?(:irbm_uuid) && irbm_uuid.present?
    end

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # extra columns vs GR (cash purchase includes immediate payment):
    # eiv_utc/eiv_received_utc/eiv_validated_utc - e-Invoice timestamps
    # landingcost1/2/localtotalwithcost           - Import costs
    # p_docno          - Payment Document No
    # p_paymentmethod  - Payment Method (Cash/Cheque/Transfer)
    # p_chequenumber   - Cheque Number
    # p_paymentproject - Payment Project
    # p_bankcharge     - Bank Charge Amount
    # p_bankchargeaccount - Bank Charge GL Account
    # p_amount         - Payment Amount
    # irbm_status/irbm_internalid/irbm_uuid/irbm_longid - MyInvois fields
    # peppol_uuid/peppol_docuuid - Peppol e-invoicing fields
  end
end
