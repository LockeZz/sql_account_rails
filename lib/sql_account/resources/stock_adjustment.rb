module SqlAccount
  class StockAdjustment < Record
    self.table_name = 'st_aj'
    self.primary_key = 'dockey'

    has_many :lines,
      class_name: 'SqlAccount::StockAdjustmentLine',
      foreign_key: 'dockey',
      primary_key: 'dockey',
      dependent: :destroy

    # validations — mirrors eStream SDK mandatory fields
    validates :docno,    presence: true
    validates :docdate,  presence: true
    validates :postdate, presence: true

    # callbacks
    before_destroy :check_not_cancelled
    after_destroy  :note_st_tr_reversal_required

    # scopes
    scope :active,     -> { where(cancelled: false) }
    scope :cancelled,  -> { where(cancelled: true) }
    scope :written_off,-> { where(writeoff: true) }
    scope :approved,   -> { where(approvestate: nil) } # placeholder — confirm actual value
    scope :by_date,    ->(date) { where(docdate: date) }
    scope :between,    ->(from, to) { where(docdate: from..to) }

    # columns:
    # (2 Unknown computed cols — likely derived totals)
    # dockey       - Primary Key
    # docno        - Document No (business key)
    # docdate      - Document Date
    # postdate     - Post Date
    # description  - Document Description
    # area         - Area
    # agent        - Agent
    # writeoff     - Write Off flag (boolean)
    # cancelled    - Cancelled flag (boolean)
    # status       - Status (integer)
    # docamt       - Document Total Amount
    # attachments  - Attachments (Binary/Blob)
    # authby       - Authorized By
    # reason       - Adjustment Reason
    # remark       - Remark
    # note         - Notes (Binary/Blob)
    # approvestate - Approval Workflow State (Binary/Blob)
    # updatecount  - Update Count
    # printcount   - Print Count
    # lastmodified - Last Modified (Unix timestamp integer)


    # Safe line update — mirrors eStream SDK pattern (delete all, reinsert)
    # Usage: adjustment.update_lines([{ seq: 1, itemcode: 'ANT', qty: 2, uom: 'PCS', unitcost: 80, amount: 160 }, ...])
    def update_lines(line_list)
      lines.delete_all
      line_list.each_with_index do |l, i|
        lines.create!(l.merge(seq: l[:seq] || i + 1))
      end
    end

    # Cancel instead of delete — safer than hard delete since SQL Account
    # tracks cancelled docs rather than removing them
    def cancel!
      update!(cancelled: true)
    end

    def cancelled?
      cancelled == true
    end

    private

    # Prevent destroy of non-cancelled documents — mirror SQL Account's
    # own safeguard (cancelled docs only)
    def check_not_cancelled
      unless cancelled?
        errors.add(:base, "Cannot delete stock adjustment '#{docno}' — cancel it first")
        throw(:abort)
      end
    end

    # IMPORTANT: Direct DB delete does NOT auto-reverse ST_TR entries
    # that SQL Account's app layer would normally handle.
    # This warning reminds developers to handle ST_TR reversal manually
    # if hard-deleting is absolutely required.
    def note_st_tr_reversal_required
      Rails.logger.warn(
        "[SqlAccount] StockAdjustment #{docno} (dockey: #{dockey}) was hard-deleted. " \
        "ST_TR transaction entries for this document were NOT automatically reversed. " \
        "Stock balances may be inconsistent — verify ST_TR manually."
      )
    end
  end
end