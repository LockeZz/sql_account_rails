module SqlAccount
  module DateValidation
    extend ActiveSupport::Concern

    included do
      validate :postdate_within_allowed_range, if: -> { respond_to?(:postdate) && postdate.present? }
    end

    private

    def postdate_within_allowed_range
      return unless postdate.present?

      unless SqlAccount::SyAllowDate.allowed?(postdate)
        allowed = SqlAccount::SyAllowDate.active
        if allowed
          errors.add(:postdate,
            "#{postdate.strftime('%d/%m/%Y')} is outside the allowed transaction date range " \
            "(#{allowed.datefrom.strftime('%d/%m/%Y')} — #{allowed.dateto.strftime('%d/%m/%Y')})"
          )
        else
          errors.add(:postdate, "no allowed transaction date range is configured in SQL Account")
        end
      end
    rescue => e
      Rails.logger.warn("[SqlAccount] DateValidation check failed: #{e.message}") if defined?(Rails.logger)
    end
  end
end