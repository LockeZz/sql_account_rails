module SqlAccount
  module PurchaseDocument
    extend ActiveSupport::Concern

    included do
      # ── Supplier association ──────────────────────────────────────
      belongs_to :supplier,
        class_name: 'SqlAccount::Supplier',
        foreign_key: 'code',
        primary_key: 'code',
        optional: true # some docs may not have a registered supplier

      scope :active, -> { where(cancelled: false) }
      scope :cancelled, -> { where(cancelled: true) }
      scope :transferable, -> { where(transferable: true) }
      scope :for_supplier, -> (code) { where(code: code) }
      scope :by_date, -> (date) { where(docdate: date) }
      scope :between, -> (from, to) { where(docdate: from..to) }
      scope :for_project, -> (proj) { where(project: proj) }
      scope :for_currency, -> (curr) { where(currencycode: curr) }

      after_destroy :not_gl_reversal_required

      validates :docno, presence: true
      validates :docdate, presence: true
      validates :postdate, presence: true

      default_scope { select(column_names - %w[attachments note approvestate]) }
    end

    def cancelled?
      cancelled = true
    end

    def cancel!
      update!(cancelled: true)
    end

    def mutli_currency?
      currencycode.present? && currencycode != "----"
    end

    def transferable?
      tranferable == true
    end

    private 

    def note_gl_reversal_required
      Rails.logger.warn(
        "[SqlAccount] #{self.class.name} #{docno} (dockey: #{dockey}) was hard-deleted. " \
        "GL postings were NOT automatically reversed. Verify ledger balances manually."
      )
    end

  end
end