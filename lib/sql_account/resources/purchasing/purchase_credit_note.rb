module SqlAccount
  class PurchaseCreditNote < Record
    self.table_name = 'ph_pc'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::PurchaseCreditNoteLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    before_destroy :check_not_knocked_off

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    private

    def check_not_knocked_off
      if knocked_off?
        errors.add(:base, "Cannot delete Purchase Credit Note '#{docno}' — it has been knocked off")
        throw(:abort)
      end
    end

    def knocked_off?
      ActiveRecord::Base.connection.execute(
        "SELECT FIRST 1 1 FROM ap_knockoff WHERE dockey2 = #{dockey}"
      ).first.present?
    rescue
      false
    end

    # NOTE: ph_pc table is empty in TESTING.FDB — schema confirmed from column inspection.
    # Minimal header vs other PH docs: no eiv fields, no irbm fields, no landingcost,
    # no transferable — this is a simpler GL-level credit note, not a stock-affecting document.
  end
end
