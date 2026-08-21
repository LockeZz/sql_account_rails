module SqlAccount
  module SalesDocument
    extend ActiveSupport::Concern

    included do
      belongs_to :customer,
        class_name: 'SqlAccount::Customer',
        foreign_key: 'code',
        primary_key: 'code',
        optiona: true

      belongs_to :project,
        class_name: 'SqlAccount::Project',
        foreign_key: 'project',
        primary_key: 'code',
        optional: true
    
      scope :active,       -> { where(cancelled: false) }
      scope :cancelled,    -> { where(cancelled: true) }
      scope :transferable, -> { where(transferable: true) }
      scope :for_customer, ->(code)     { where(code: code) }
      scope :by_date,      ->(date)     { where(docdate: date) }
      scope :between,      ->(from, to) { where(docdate: from..to) }
      scope :for_project,  ->(proj)     { where(project: proj) }
      scope :for_currency, ->(curr)     { where(currencycode: curr) }

      scope :eiv_submitted,  -> { where.not(irbm_uuid: nil) }
      scope :eiv_validated,  -> { where.not(eiv_validated_utc: nil) }
      scope :eiv_pending,    -> { where(irbm_uuid: nil) }

      after_destroy :note_gl_reversal_required
      validates :docno,    presence: true
      validates :docdate,  presence: true
      validates :postdate, presence: true

      default_scope { select(column_names - %w[attachments note approvestate]) }
    end


    def cancelled?
      cancelled == true
    end

    def cancel!
      update!(cancelled: true)
    end

    def multi_currency?
      currencycode.present? && currencycode != '----'
    end

    def transferable?
      transferable == true
    end

    def has_project?
      project.present? && project != '----'
    end

    def eiv_submitted?
      respond_to?(:irbm_uuid) && irbm_uuid.present?
    end

    def eiv_validated?
      respond_to?(:eiv_validated_utc) && eiv_validated_utc.present?
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
