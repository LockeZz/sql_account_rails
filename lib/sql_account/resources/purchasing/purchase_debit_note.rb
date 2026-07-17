module SqlAccount
  class PurchaseDebitNote < Record
    self.table_name = 'ph_sd'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::DebitNoteLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # e-Invoice / MyInvois scopes
    scope :eiv_submitted, -> { where.not(irbm_uuid: nil) }
    scope :eiv_validated, -> { where.not(eiv_validated_utc: nil) }

    def eiv_submitted?
      irbm_uuid.present?
    end

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # extra columns vs shared header:
    # eiv_utc/eiv_received_utc/eiv_validated_utc - e-Invoice timestamps
    # landingcost1/2/localtotalwithcost           - Import costs
    # fromdoc          - Source document reference (on HEADER, not detail)
    #                    NOTE: debit note links source doc at header level,
    #                    unlike other docs that link at detail line level
    # irbm_status/irbm_internalid/irbm_uuid/irbm_longid - MyInvois fields
    # NOTE: no peppol fields on ph_sd
  end
end
