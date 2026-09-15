module SqlAccount
  class SalesInvoice < Record 

    self.table_name = 'sl_iv'
    self.primary_key = 'dockey'

    include SqlAccount::SalesDocument

    has_many :lines,
      class_name: 'SqlAccount::SalesInvoiceLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    has_many :knockoffs,
      class_name: 'SqlAccount::CustomerKnockoff'
      foreign_key: 'todockey',
      primary_key: 'dockey'

    has_many :payments, through: :knockoffs,
      class_name: 'SqlAccount::CustomerPayment',
      source: :customer_payment

    before_destroy :check_not_knocked_off

    
    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    # private

    # def check_not_knocked_off
    #   if knocked_off?
    #     errors.add(:base, "Cannot delete Sales Invoice '#{docno}' — it has been knocked off by a Payment or Credit Note")
    #     throw(:abort)
    #   end
    # end

    # def knocked_off?
    #   SqlAccount::Record.connection.execute(
    #     "SELECT FIRST 1 1 FROM ar_knockoff WHERE dockey2 = #{dockey}"
    #   ).first.present?
    # rescue
    #   false
    # end

    # extra columns specific to SL_IV (on top of shared header):
    # eiv_utc/eiv_received_utc/eiv_validated_utc - e-Invoice timestamps
    # eivrequest_uuid      - e-Invoice request UUID (extra field vs purchase side)
    # irbm_status/irbm_internalid/irbm_uuid/irbm_longid - MyInvois fields
    # peppol_uuid/peppol_docuuid - Peppol e-invoicing fields
    # d_amount             - Discount amount
    # udf_totalcontractamt - UDF: Total Contract Amount
    # udf_previousclaimamt - UDF: Previous Claim Amount
    # udf_thisinvoice      - UDF: This Invoice Amount
    # udf_totalclaimamt    - UDF: Total Claim Amount
    # udf_totalrecamt      - UDF: Total Received Amount
    # udf_variationorder   - UDF: Variation Order Amount
    # NOTE: udf_* are real DB columns (not API-only) confirmed from column inspection
  end
end