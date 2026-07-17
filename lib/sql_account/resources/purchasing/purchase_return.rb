module SqlAccount
  class PurchaseReturn < Record
    self.table_name = 'ph_sc'
    self.primary_key = 'dockey'

    include SqlAccount::PurchaseDocument

    has_many :lines,
      class_name: 'SqlAccount::PurchaseReturnLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # traceability — purchase return usually originates from a PI
    scope :from_invoice, -> { joins(:lines).where("ph_scdtl.fromdoctype = 'PI'").distinct }

    before_destroy :check_not_knocked_off

    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index { |l, i| lines.create!(l.merge(seq: l[:seq] || i + 1)) }
    end

    private

    def check_not_knocked_off
      if knocked_off?
        errors.add(:base, "Cannot delete Purchase Return '#{docno}' — it has been knocked off")
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

    # NOTE: ph_sc header was not captured in column inspection — schema assumed
    # to match standard purchase document header pattern. Verify against
    # actual database before relying on any fields not confirmed below.
    # Confirmed from ph_scdtl sample: fromdoctype = 'PI' (returns against invoices)
  end
end
